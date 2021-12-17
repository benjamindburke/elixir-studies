defmodule TodoServer do
  # ---------
  # Synchronous generic abstracted functions, invoked in the server process
  # ---------

  def init do
    TodoList.new()
  end

  # READ
  # ---------
  def handle_call({:entries, query}, todo_list) do
    # cast is used here because the function we invoked to query data
    # is not a function that modifies data, so it cannot return the result of that call
    # thus, we send a tuple of our query result and the unmodified todo_list
    {TodoList.entries(todo_list, query), todo_list}
  end

  # ---------
  # Aynchronous generic abstracted functions, invoked in the server process
  # ---------

  # CREATE
  # ---------
  def handle_cast({:add_entry, new_entry}, todo_list) do
    TodoList.add_entry(todo_list, new_entry)
  end

  # DELETE
  # ---------
  def handle_cast({:delete_entry, id}, todo_list) do
    TodoList.delete_entry(todo_list, id)
  end

  # UPDATE
  # ---------
  def handle_cast({:update_entry, entry_id, updater_fun}, todo_list) do
    TodoList.update_entry(todo_list, entry_id, updater_fun)
  end

  # ---------
  # Interface functions (invoked by the client)
  # ---------

  def start do
    ServerProcess.start(TodoServer)
  end

  def add_entry(todo_server, new_entry) do
    ServerProcess.cast(todo_server, {:add_entry, new_entry})
    :ok
  end

  def entries(todo_server, query) do
    ServerProcess.call(todo_server, {:entries, query})
  end

  def delete_entry(todo_server, id) do
    ServerProcess.cast(todo_server, {:delete_entry, id})
    :ok
  end

  def update_entry(todo_server, %{} = new_entry) do
    ServerProcess.cast(todo_server, {:update_entry, new_entry.id, fn _ -> new_entry end})
    :ok
  end
end

defmodule TodoList do
  @doc "auto_id will contain the ID value assigned to the new entry"
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)
    %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  def entries(todo_list, %Date{} = date) do
    todo_list.entries()
    |> Stream.filter(fn {_, entry} -> entry.date == date end) # Filters entries for a given date
    |> Enum.map(fn {_, entry} -> entry end) # Takes only values
  end

  def entries(todo_list, title) when is_binary(title) do
    todo_list.entries()
    |> Stream.filter(fn {_, entry} -> entry.title == title end) # Filters entries for a given date
    |> Enum.map(fn {_, entry} -> entry end) # Takes only values
  end

  def entries(todo_list, id) when is_integer(id) do
    Map.get(todo_list.entries, id)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    # TODO : when updating an entry, why is the entire entry overwritten and the two don't merge?
    case Map.fetch(todo_list.entries, entry_id) do
      :error -> todo_list
      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, Map.merge(new_entry, todo_list.entries[new_entry.id], fn _k, v1, _v2 -> v1 end))
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def delete_entry(todo_list, id) do
    Map.delete(todo_list.entries, id)
  end
end

defimpl Collectable, for: TodoList do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    TodoList.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done) do
    todo_list
  end

  defp into_callback(_todo_list, :halt) do
    :ok
  end
end

# ServerProcess
# A generic server implementation to illustrate how GenServer works
defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      # callback_module must have an exported init/1 function
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        # send the request to be handled by the callback_module
        {response, new_state} = callback_module.handle_call(request, current_state)
        # sends the response back to the caller
        send(caller, {:response, response})
        # keep looping the server process with the new state
        loop(callback_module, new_state)
      {:cast, request} ->
        new_state = callback_module.handle_cast(request, current_state)
        # keep looping the server process with the new state
        loop(callback_module, new_state)
    end
  end

  # ---------
  # Synchronous generic functions
  # ---------

  def call(server_pid, request) do
    # send the server a request
    send(server_pid, {:call, request, self()})
    receive do
      # wait for response and return
      {:response, response} ->
        response
    end
  end

  # ---------
  # Asynchronous generic functions
  # ---------

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end
end

# TEST CODE
# ---------

# entries = [
#     %{date: ~D[2018-12-19], title: "Dentist"},
#     %{date: ~D[2018-12-20], title: "Shopping"},
#     %{date: ~D[2018-12-19], title: "Movies"}
# ]
# server = TodoServer.start()
# Enum.each(entries, &TodoServer.add_entry(server, &1))
# TodoServer.entries(server, ~D[2018-12-19])
# TodoServer.entries(server, 1)
# TodoServer.update_entry(server, %{id: 2, title: "Feeding Pesto"})
# TodoServer.add_entry(server, %{date: ~D[2021-11-08], title: "Feeding Pesto"})
# TodoServer.entries(server, "Feeding Pesto")
# TodoServer.delete_entry(server, 4)

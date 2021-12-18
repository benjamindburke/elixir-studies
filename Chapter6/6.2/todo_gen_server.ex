defmodule TodoServer do
  use GenServer

  # ---------
  # GenServer hook functions
  # ---------

  @impl GenServer
  def init(entries) do
    {:ok, TodoList.new(entries)}
  end

  # READ
  # ---------
  @impl GenServer
  def handle_call({:entries, query}, _, todo_list) do
    {:reply, TodoList.entries(todo_list, query), todo_list}
  end

  # CREATE
  # ---------
  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo_list) do
    {:noreply, TodoList.add_entry(todo_list, new_entry)}
  end

  # UPDATE
  # ---------
  @impl GenServer
  def handle_cast({:update_entry, new_entry}, todo_list) do
    {:noreply, TodoList.update_entry(todo_list, new_entry)}
  end

  # DELETE
  # ---------
  @impl GenServer
  def handle_cast({:delete_entry, id}, todo_list) do
    {:noreply, TodoList.delete_entry(todo_list, id)}
  end

  # ---------
  # Interface functions
  # ---------

  # START
  # ---------
  def start(entries \\ []) do
    # entries is the first argument sent to the init/1 GenServer hook
    GenServer.start(__MODULE__, entries, name: __MODULE__)
  end

  # CREATE
  # ---------
  def add_entry(entry) do
    GenServer.cast(__MODULE__, {:add_entry, entry})
  end

  # READ
  # ---------
  def entries(query) do
    GenServer.call(__MODULE__, {:entries, query})
  end

  # UPDATE
  # ---------
  def update_entry(%{} = new_entry) do
    GenServer.cast(__MODULE__, {:update_entry, new_entry})
  end

  # DELETE
  # ---------
  def delete_entry(id) do
    GenServer.cast(__MODULE__, {:delete_entry, id})
  end
end

defmodule TodoList do
  @doc "auto_id will contain the ID value assigned to the new entry"
  defstruct auto_id: 1, entries: %{}

  def new(entries) do
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
    new_entries = Map.delete(todo_list.entries, id)
    %TodoList{todo_list | entries: new_entries}
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

# TEST CODE
# ---------

# entries = [
#     %{date: ~D[2018-12-19], title: "Dentist"},
#     %{date: ~D[2018-12-20], title: "Shopping"},
#     %{date: ~D[2018-12-19], title: "Movies"}
# ]
# TodoServer.start(entries)
# TodoServer.entries(~D[2018-12-19])
# TodoServer.entries(1)
# TodoServer.update_entry(%{id: 2, title: "Feeding Pesto"})
# TodoServer.add_entry(%{date: ~D[2021-11-08], title: "Feeding Pesto"})
# TodoServer.entries("Feeding Pesto")
# TodoServer.delete_entry(4)
# TodoServer.entries(1)
# TodoServer.entries("Feeding Pesto")

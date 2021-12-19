# compile using `iex -S mix compile`

defmodule Todo.Server do
  use GenServer

  # ---------
  # GenServer hook functions
  # ---------

  @impl GenServer
  def init({name, entries}) do
    # be careful of writing long init/1 functions
    # remember that other dependencies cannot interact with the server while init/1 is running
    # because GenServer blocks interactions until init/1 finishes

    {:ok, {name, Todo.Database.get(name) || Todo.List.new(entries)}}

    # to circumvent this, we can send our own module a message to perform some setup in the handle_info hook
    # send(self(), :real_init)
    # {:ok, nil}
  end

  # READ
  # ---------
  @impl GenServer
  def handle_call({:entries, query}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, query), {name, todo_list}}
  end

  # CREATE
  # ---------
  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  # UPDATE
  # ---------
  @impl GenServer
  def handle_cast({:update_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  # DELETE
  # ---------
  @impl GenServer
  def handle_cast({:delete_entry, id}, {name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, id)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  # @impl GenServer
  # def handle_info(:real_init, _) do
  #   {:reply, {name, Todo.Database.get(name) || Todo.List.new(entries)}}
  # end

  # ---------
  # Interface functions
  # ---------

  # START
  # ---------
  def start(name, entries \\ []) do
    GenServer.start(__MODULE__, {name, entries})
  end

  # CREATE
  # ---------
  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  # READ
  # ---------
  def entries(pid, query) do
    GenServer.call(pid, {:entries, query})
  end

  # UPDATE
  # ---------
  def update_entry(pid, %{} = new_entry) do
    GenServer.cast(pid, {:update_entry, new_entry})
  end

  # DELETE
  # ---------
  def delete_entry(pid, id) do
    GenServer.cast(pid, {:delete_entry, id})
  end
end

# TEST CODE
# ---------

# entries = [
#     %{date: ~D[2018-12-19], title: "Dentist"},
#     %{date: ~D[2018-12-20], title: "Shopping"},
#     %{date: ~D[2018-12-19], title: "Movies"}
# ]
# {:ok, cache} = Todo.Cache.start()
# bobs_list = Todo.Cache.server_process(cache, "bobs_list")
# Enum.each(entries, &Todo.Server.add_entry(bobs_list, &1))
# Todo.Server.entries(bobs_list, 1)
# Todo.Server.update_entry(bobs_list, %{id: 2, title: "Feeding Pesto"})
# Todo.Server.add_entry(bobs_list, %{date: ~D[2021-11-08], title: "Feeding Pesto"})
# Todo.Server.entries(bobs_list, "Feeding Pesto")
# Todo.Server.delete_entry(bobs_list, 4)
# Todo.Server.entries(bobs_list, 1)
# Todo.Server.entries(bobs_list, "Feeding Pesto")
# Todo.Database.get("bobs_list")
# ...shut down
# Todo.Cache.start()
# bobs_list = Todo.Database.get("bobs_list")
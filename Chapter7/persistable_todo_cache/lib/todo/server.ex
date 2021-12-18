# compile using `iex -S mix compile`

defmodule Todo.Server do
  use GenServer

  # ---------
  # GenServer hook functions
  # ---------

  @impl GenServer
  def init(entries) do
    {:ok, Todo.List.new(entries)}
  end

  # READ
  # ---------
  @impl GenServer
  def handle_call({:entries, query}, _, todo_list) do
    {:reply, Todo.List.entries(todo_list, query), todo_list}
  end

  # CREATE
  # ---------
  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo_list) do
    {:noreply, Todo.List.add_entry(todo_list, new_entry)}
  end

  # UPDATE
  # ---------
  @impl GenServer
  def handle_cast({:update_entry, new_entry}, todo_list) do
    {:noreply, Todo.List.update_entry(todo_list, new_entry)}
  end

  # DELETE
  # ---------
  @impl GenServer
  def handle_cast({:delete_entry, id}, todo_list) do
    {:noreply, Todo.List.delete_entry(todo_list, id)}
  end

  # ---------
  # Interface functions
  # ---------

  # START
  # ---------
  def start(entries \\ []) do
    # entries is the first argument sent to the init/1 GenServer hook

    # when using a cache or connection manager, you cannot specify the name: __MODULE__!!
    # doing so will create a single pid which is referred to in all calls
    # when the module must be started with multiple pids, the name registration must be removed

    GenServer.start(__MODULE__, entries)
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
# Todo.Server.start(entries)
# Todo.Server.entries(~D[2018-12-19])
# Todo.Server.entries(1)
# Todo.Server.update_entry(%{id: 2, title: "Feeding Pesto"})
# Todo.Server.add_entry(%{date: ~D[2021-11-08], title: "Feeding Pesto"})
# Todo.Server.entries("Feeding Pesto")
# Todo.Server.delete_entry(4)
# Todo.Server.entries(1)
# Todo.Server.entries("Feeding Pesto")
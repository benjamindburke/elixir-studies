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
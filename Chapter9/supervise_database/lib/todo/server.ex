# compile using `iex -S mix compile`

defmodule Todo.Server do
  use GenServer

  # ---------
  # Interface functions
  # ---------

  # START
  # ---------
  def start_link(name, entries \\ []) do
    IO.puts("Starting to-do server for #{name}.")
    GenServer.start_link(__MODULE__, {name, entries})
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

  # ---------
  # GenServer hook functions
  # ---------

  @impl GenServer
  def init({name, entries}) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new(entries)}}
    # send(self(), :real_init) # uncomment to hook into handle_info(:real_init, ...) callback
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
end

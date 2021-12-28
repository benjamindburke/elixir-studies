# Todo Server [dynamic worker]
# This module manipulates and queries a client's to-do list
defmodule Todo.Server do
  use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.seconds(10)

  # ---------
  # Interface functions
  # ---------

  # CREATE
  # ---------
  @spec add_entry(pid, map) :: :ok
  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  # READ
  # ---------
  @spec entries(pid, any) :: list
  def entries(pid, query) do
    GenServer.call(pid, {:entries, query})
  end

  # UPDATE
  # ---------
  @spec update_entry(pid, map) :: :ok
  def update_entry(pid, %{} = new_entry) do
    GenServer.cast(pid, {:update_entry, new_entry})
  end

  # DELETE
  # ---------
  @spec delete_entry(pid, integer) :: :ok
  def delete_entry(pid, id) do
    GenServer.cast(pid, {:delete_entry, id})
  end

  # ---------
  # DynamicSupervisor hook functions
  # ---------

  @spec start_link(charlist, list | nil) :: {:error, any} | {:ok, pid}
  def start_link(name, entries \\ []) do
    IO.puts("Starting to-do server for #{name}.")
    GenServer.start_link(__MODULE__, {name, entries}, name: via_tuple(name))
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  # ---------
  # GenServer hook functions
  # ---------

  @impl GenServer
  def init({name, entries}) do
    {
      :ok,
      {name, Todo.Database.get(name) || Todo.List.new(entries)},
      @expiry_idle_timeout
    }
  end

  # READ
  # ---------
  @impl GenServer
  def handle_call({:entries, query}, _, {name, todo_list}) do
    {
      :reply,
      Todo.List.entries(todo_list, query),
      {name, todo_list},
      @expiry_idle_timeout
    }
  end

  # CREATE
  # ---------
  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {
      :noreply,
      {name, new_list},
      @expiry_idle_timeout
    }
  end

  # UPDATE
  # ---------
  @impl GenServer
  def handle_cast({:update_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {
      :noreply,
      {name, new_list},
      @expiry_idle_timeout
    }
  end

  # DELETE
  # ---------
  @impl GenServer
  def handle_cast({:delete_entry, id}, {name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, id)
    Todo.Database.store(name, new_list)
    {
      :noreply,
      {name, new_list},
      @expiry_idle_timeout
    }
  end

  # TIMEOUT
  # ---------
  @impl GenServer
  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping to-do server for #{name}")
    {:stop, :normal, {name, todo_list}}
  end
end

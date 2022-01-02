# Todo Server [dynamic worker, distributed]
# This module manipulates and queries a client's to-do list
defmodule Todo.Server do
  use GenServer, restart: :temporary

  # ---------
  # Interface functions
  # ---------

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
  # DynamicSupervisor hook functions
  # ---------

  def start_link(name, entries \\ []) do
    IO.puts("Starting to-do server for #{name}.")
    GenServer.start_link(__MODULE__, {name, entries}, name: global_name(name))
  end

  # ---------
  # GenServer hook functions
  # ---------

  @impl GenServer
  def init({name, entries}) do
    expiry = cache_expiry()
    {
      :ok,
      {name, Todo.Database.get(name) || Todo.List.new(entries), expiry},
      expiry
    }
  end

  # READ
  # ---------
  @impl GenServer
  def handle_call({:entries, query}, _, {name, todo_list, expiry}) do
    {
      :reply,
      Todo.List.entries(todo_list, query),
      {name, todo_list, expiry},
      expiry
    }
  end

  # CREATE
  # ---------
  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list, expiry}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {
      :noreply,
      {name, new_list, expiry},
      expiry
    }
  end

  # UPDATE
  # ---------
  @impl GenServer
  def handle_cast({:update_entry, new_entry}, {name, todo_list, expiry}) do
    new_list = Todo.List.update_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {
      :noreply,
      {name, new_list, expiry},
      expiry
    }
  end

  # DELETE
  # ---------
  @impl GenServer
  def handle_cast({:delete_entry, id}, {name, todo_list, expiry}) do
    new_list = Todo.List.delete_entry(todo_list, id)
    Todo.Database.store(name, new_list)
    {
      :noreply,
      {name, new_list, expiry},
      expiry
    }
  end

  # TIMEOUT
  # ---------
  @impl GenServer
  def handle_info(:timeout, {name, todo_list, expiry}) do
    IO.puts("Timeout of to-do server #{name}")
    {:stop, :normal, {name, todo_list, expiry}}
  end

  # ---------
  # Helper functions
  # ---------

  defp cache_expiry() do
    Application.fetch_env!(:todo, :todo_item_expiry)
  end

  defp global_name(name) do
    {:global, {__MODULE__, name}}
  end

  def whereis(name) do
    case :global.whereis_name({__MODULE__, name}) do
      :undefined -> nil
      pid -> pid
    end
  end
end

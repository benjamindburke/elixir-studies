# Todo DatabaseWorker [worker]
# This module handles storage and retrieval of a single to-do list's stored queries
defmodule Todo.WebCacheWorker do
  use GenServer

  # ---------
  # Interface functions
  # ---------

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  # ---------
  # Supervisor hook functions
  # ---------

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  # ---------
  # GenServer hook functions
  # ---------

  @impl GenServer
  def init(_) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, state) do
    result = :ets.insert_new(Todo.WebCache, {key, data})
    if result do
      IO.puts("Web Cache: added new query entry.")
    end
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get, key}, _, state) do
    data = case :ets.lookup(Todo.WebCache, key) do
      [{^key, data}] ->
        IO.puts("Serving response via web cache.")
        data
      _ -> nil
    end
    {:reply, data, state}
  end
end

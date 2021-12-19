defmodule Todo.Database do
use GenServer

  @db_folder "./persist"
  @worker_count 3

  def start do
    # registering the process locally will force the process to only run once
    # this is very useful if one module needs to orchestrate other processes
    # or manage some shared state between process
    # thus, locally registered processes can become synchronization locks
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:put, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @impl GenServer
  def init(_) do
    workers =
      for worker <- 0..(@worker_count - 1),
        into: %{} do
        {worker, Todo.DatabaseWorker.start(@db_folder)}
      end
    {:ok, workers}
  end

  @impl GenServer
  def handle_cast({:put, key, data}, workers) do
    spawn(fn ->
      worker = choose_worker(workers, key)
      Todo.DatabaseWorker.store(worker, key, data)
    end)

    {:noreply, workers}
  end

  @impl GenServer
  def handle_call({:get, key}, caller, workers) do
    spawn(fn ->
      worker = choose_worker(workers, key)
      data = Todo.DatabaseWorker.get(worker, key)
      GenServer.reply(caller, data)
    end)

    {:no_reply, workers}
  end

  defp choose_worker(workers, key) do
    Map.get(workers, :erlang.phash2(key, 3))
  end
end
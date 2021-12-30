# Todo Database [supervisor]
# This module supervises the creation of database workers
defmodule Todo.Database do
  @db_folder "./persist"
  @pool_size 3

  # ---------
  # Interface functions
  # ---------

  @spec store(charlist, any) :: :ok
  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  @spec get(charlist) :: any
  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  # ---------
  # Supervisor hook functions
  # ---------

  def start_link do
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  # ---------
  # Helper functions
  # ---------

  @spec choose_worker(charlist) :: integer
  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end

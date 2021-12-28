# Todo Database
# This supervisor process handles the creation and lookup of database workers up to a certain pool size.
defmodule Todo.Database do
  @db_folder "./persist"
  @pool_size 3

  # ---------
  # Interface functions
  # ---------

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  # ---------
  # DynamicSupervisor hook functions
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

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end

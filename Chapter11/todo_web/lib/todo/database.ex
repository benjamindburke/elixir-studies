# Todo Database [supervisor]
# This module supervises the creation of database workers
defmodule Todo.Database do
  @db_folder "./persist"
  @pool_size 3

  # ---------
  # Interface functions
  # ---------

  def store(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid -> Todo.DatabaseWorker.store(worker_pid, key, data) end
    )
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid -> Todo.DatabaseWorker.get(worker_pid, key) end
    )
  end

  def child_spec(_) do
    File.mkdir_p!(@db_folder)
    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: @pool_size
      ],
      [@db_folder] # worker arguments
    )
  end
end

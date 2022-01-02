# Todo Database [supervisor]
# This module supervises the creation of database workers
defmodule Todo.Database do

  # ---------
  # Interface functions
  # ---------

  @doc """
    store/2 performs an RPC multicall to all Todo.Database nodes,
    calling each Todo.Database node's store_local/2 function,
    thereby replicating all data to all database nodes.
  """
  def store(key, data) do
    {_results, bad_nodes} =
      :rpc.multicall(
        __MODULE__,
        :store_local,
        [key, data],
        :timer.seconds(5)
      )

    Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))
  end

  @doc """
    store_local/2 stores the {key, data} pair in a
    local binary file at the file path database_folder/node/key
  """
  def store_local(key, data) do
    :poolboy.transaction(__MODULE__, fn worker_pid ->
      Todo.DatabaseWorker.store(worker_pid, key, data)
    end)
  end

  def get(key) do
    :poolboy.transaction(__MODULE__, fn worker_pid ->
      Todo.DatabaseWorker.get(worker_pid, key)
    end)
  end

  # ---------
  # Supervisor hook functions
  # ---------

  def child_spec(_) do
    db_settings = Application.fetch_env!(:todo, :database)

    # Node name is used to determine the database folder. This allows us to
    # start multiple nodes form the same folders, and data will not clash.
    [name_prefix, _] = "#{node()}" |> String.split("@")
    db_folder = "#{Keyword.fetch!(db_settings, :folder)}/#{name_prefix}/"

    File.mkdir_p!(db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: Keyword.fetch!(db_settings, :pool_size)
      ],
      [db_folder] # worker arguments
    )
  end
end

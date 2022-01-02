# Todo WebCache [supervisor]
# This module supervises the creation of web cache workers
defmodule Todo.WebCache do

  # ---------
  # Interface functions
  # ---------

  def store(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid -> Todo.WebCacheWorker.store(worker_pid, key, data) end
    )
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid -> Todo.WebCacheWorker.get(worker_pid, key) end
    )
  end

  # ---------
  # Supervisor hook functions
  # ---------

  def child_spec(_) do
    init()
    web_cache_settings = Application.fetch_env!(:todo, :cache)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.WebCacheWorker,
        size: Keyword.fetch!(web_cache_settings, :pool_size)
      ],
      [] # worker arguments
    )
  end

  # ---------
  # Helper functions
  # ---------

  def init do
    IO.puts("Starting to-do web cache.")
    :ets.new(
      __MODULE__,
      [
        :named_table,
        :public,
        :ordered_set,
        write_concurrency: true
      ]
    )
  end
end

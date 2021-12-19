defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start do
    # registering the process locally will force the process to only run once
    # this is very useful if one module needs to orchestrate other processes
    # or manage some shared state between process
    # thus, locally registered processes can become synchronization locks
    GenServer.start(
      __MODULE__,
      nil,
      name: __MODULE__ # locally register the process
    )
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:put, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_folder)
    {:ok, nil}
  end

  @impl GenServer
  def handle_cast({:put, key, data}, state) do
    # the upside of using cast in this persist function is that
    # the client can continue its execution if it doesn't care about the result
    # this behavior also allows casts to be far more scalable that calls
    # the downside of using cast is that sometimes you will need to verify if the data was persisted
    key
    |> file_name()
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get, key}, _, state) do
    data = case File.read(file_name(key)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end

    {:reply, data, state}
  end

  defp file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
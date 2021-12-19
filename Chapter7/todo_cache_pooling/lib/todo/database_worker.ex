defmodule Todo.DatabaseWorker do
  use GenServer

  def start(folder) do
    GenServer.start(__MODULE__, folder)
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:put, key, data})
  end

  @impl GenServer
  def init(folder) do
    File.mkdir_p!(folder)
    {:ok, folder}
  end

  @impl GenServer
  def handle_cast({:put, key, data}, folder) do
    # the upside of using cast in this persist function is that
    # the client can continue its execution if it doesn't care about the result
    # this behavior also allows casts to be far more scalable that calls
    # the downside of using cast is that sometimes you will need to verify if the data was persisted
    spawn(fn ->
      folder
      |> file_name(key)
      |> File.write!(:erlang.term_to_binary(data))
    end)

    {:noreply, folder}
  end

  @impl GenServer
  def handle_call({:get, key}, caller, folder) do
    spawn(fn ->
      data = case File.read(file_name(folder, key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

      GenServer.reply(caller, data)
    end)

    {:noreply, folder}
  end

  defp file_name(folder, key) do
    Path.join(folder, to_string(key))
  end
end
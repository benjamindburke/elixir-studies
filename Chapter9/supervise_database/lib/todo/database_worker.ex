defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link(folder) do
    IO.puts("Starting database worker.")
    GenServer.start_link(__MODULE__, folder)
  end

  def store(worker, key, data) do
    GenServer.cast(worker, {:store, key, data})
  end

  def get(worker, key) do
    GenServer.call(worker, {:get, key})
  end

  @impl GenServer
  def init(folder) do
    File.mkdir_p!(folder)
    {:ok, folder}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, folder) do
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

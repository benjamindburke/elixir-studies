# Todo DatabaseWorker [worker]
# This module handles storage and retrieval of a single to-do list's data
defmodule Todo.DatabaseWorker do
  use GenServer

  # ---------
  # Interface functions
  # ---------

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  # ---------
  # Supervisor hook functions
  # ---------

  def start_link({folder, worker_id}) do
    IO.puts("Starting database worker #{worker_id}")
    GenServer.start_link(
      __MODULE__,
      folder,
      name: via_tuple(worker_id)
    )
  end

  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end

  # ---------
  # GenServer hook functions
  # ---------

  @impl GenServer
  @spec init(binary) :: {:ok, binary}
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

  # ---------
  # Helper functions
  # ---------

  @spec file_name(binary, charlist) :: binary
  defp file_name(folder, key) do
    Path.join(folder, to_string(key))
  end
end

# Todo DatabaseWorker [worker]
# This module handles storage and retrieval of a single to-do list's data
defmodule Todo.DatabaseWorker do
  use GenServer

  # ---------
  # Interface functions
  # ---------

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  # ---------
  # Supervisor hook functions
  # ---------

  def start_link(folder) do
    GenServer.start_link(__MODULE__, folder)
  end

  # ---------
  # GenServer hook functions
  # ---------

  @impl GenServer
  def init(folder) do
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

  defp file_name(folder, key) do
    Path.join(folder, to_string(key))
  end
end

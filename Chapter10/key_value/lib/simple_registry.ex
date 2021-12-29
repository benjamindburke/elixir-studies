defmodule SimpleRegistry do
  use GenServer

  # ---------
  # Interfaces
  # ---------

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(key) do
    GenServer.call(__MODULE__, {:register, key, self()})
  end

  def whereis(key) do
    GenServer.call(__MODULE__, {:whereis, key})
  end

  # ---------
  # GenServer hook functions
  # ---------

  @impl GenServer
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:register, key, pid}, _, registry) do
    case Map.get(registry, key) do
      nil ->
        Process.link(pid)
        {:reply, :ok, Map.put(registry, key, pid)}
      _ ->
        {:reply, :error, registry}
    end
  end

  @impl GenServer
  def handle_call({:whereis, key}, _, registry) do
    {:reply, Map.get(registry, key), registry}
  end

  @impl GenServer
  def handle_info({:EXIT, pid, _reason}, registry) do
    {:noreply, deregister_pid(registry, pid)}
  end

  defp deregister_pid(registry, pid) do
    registry
    |> Enum.reject(fn {_key, process} -> process == pid end)
    |> Enum.into(%{})
  end
end

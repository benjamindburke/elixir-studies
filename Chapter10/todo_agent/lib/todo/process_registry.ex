# Todo ProcessRegistry [supervisor]
# This module supervises and registers all Todo services
defmodule Todo.ProcessRegistry do
  # ---------
  # Supervisor hook functions
  # ---------

  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  @spec via_tuple(charlist) :: {:via, Registry, {Todo.ProcessRegistry, charlist}}
  def via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end
end

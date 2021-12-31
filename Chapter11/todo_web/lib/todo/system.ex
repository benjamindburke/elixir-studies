# Todo System [error kernel, supervisor]
# This module initializes and supervises all Todo services on behalf of its clients
defmodule Todo.System do
  # ---------
  # Supervisor/DynamicSupervisor hook functions
  # ---------

  def start_link do
    Supervisor.start_link(
      [
        Todo.Metrics,
        Todo.ProcessRegistry,
        Todo.Database,
        Todo.Cache,
        Todo.Web
      ],
      strategy: :one_for_one
    )
  end
end

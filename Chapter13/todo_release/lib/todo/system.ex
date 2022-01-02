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
        Todo.Database,
        Todo.Cache,
        Todo.WebCache,
        Todo.Web
      ],
      strategy: :one_for_one
    )
  end
end

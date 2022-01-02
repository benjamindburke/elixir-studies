# Todo Cache [dynamic supervisor]
# This module supervises Todo.Server instances which perform a client's to-do storage and retrieval
defmodule Todo.Cache do
  # ---------
  # Interface functions
  # ---------

  def server_process(todo_list_name) do
    existing_process(todo_list_name) || new_process(todo_list_name)
  end

  # ---------
  # DynamicSupervisor hook functions
  # ---------

  def start_link do
    IO.puts("Starting to-do cache.")
    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  # ---------
  # Helper functions
  # ---------

  defp existing_process(todo_list_name) do
    Todo.Server.whereis(todo_list_name)
  end

  defp new_process(todo_list_name) do
    case DynamicSupervisor.start_child(
      __MODULE__,
      {Todo.Server, todo_list_name}
    ) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end

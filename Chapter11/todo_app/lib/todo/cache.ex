# Todo Cache [dynamic supervisor]
# This module supervises Todo.Server instances which perform a client's to-do storage and retrieval
defmodule Todo.Cache do
  # ---------
  # Interface functions
  # ---------

  @spec server_process(charlist) :: pid
  def server_process(todo_list_name) do
    case start_child(todo_list_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  # ---------
  # DynamicSupervisor hook functions
  # ---------

  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link do
    IO.puts("Starting to-do cache.")
    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  defp start_child(todo_list_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Todo.Server, todo_list_name}
    )
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end
end

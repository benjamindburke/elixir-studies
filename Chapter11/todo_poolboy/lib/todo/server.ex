# Todo Server [dynamic worker]
# This module manipulates and queries a client's to-do list
defmodule Todo.Server do
  use Agent, restart: :temporary

  # ---------
  # Interface functions
  # ---------

  # CREATE
  # ---------
  @spec add_entry(pid, map) :: :ok
  def add_entry(pid, new_entry) do
    Agent.cast(
      pid,
      fn {name, todo_list} ->
        new_list = Todo.List.add_entry(todo_list, new_entry)
        Todo.Database.store(name, new_list)
        {name, new_list}
      end
    )
  end

  # READ
  # ---------
  @spec entries(pid, any) :: list
  def entries(pid, query) do
    Agent.get(
      pid,
      fn {_name, todo_list} -> Todo.List.entries(todo_list, query) end
    )
  end

  # UPDATE
  # ---------
  @spec update_entry(pid, map) :: :ok
  def update_entry(pid, %{} = new_entry) do
    Agent.cast(
      pid,
      fn {name, todo_list} ->
        new_list = Todo.List.update_entry(todo_list, new_entry)
        Todo.Database.store(name, new_list)
        {name, new_list}
      end
    )
  end

  # DELETE
  # ---------
  @spec delete_entry(pid, integer) :: :ok
  def delete_entry(pid, id) do
    Agent.cast(
      pid,
      fn {name, todo_list} ->
        new_list = Todo.List.delete_entry(todo_list, id)
        Todo.Database.store(name, new_list)
        {name, new_list}
      end
    )
  end

  # ---------
  # DynamicSupervisor hook functions
  # ---------

  def start_link(name, entries \\ []) do
    Agent.start_link(
      fn ->
        IO.puts("Starting to-do server for #{name}.")
        {name, Todo.Database.get(name) || Todo.List.new(entries)}
      end
    )
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end

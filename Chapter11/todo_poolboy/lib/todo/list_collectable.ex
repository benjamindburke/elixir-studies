# Todo List [protocol]
# Implementation of the Collectable protocol for the Todo.List data structure
defimpl Collectable, for: Todo.List do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    Todo.List.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done) do
    todo_list
  end

  defp into_callback(_todo_list, :halt) do
    :ok
  end
end

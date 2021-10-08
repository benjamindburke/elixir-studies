# Make the TodoList collectable, so it can be used in comprehension accumulators
defimpl Collectable, for: TodoList do
    # returns the appender lambda
    def into(original) do
        {original, &into_callback/2}
    end

    # appender lambda implementation
    defp into_callback(todo_list, {:cont, entry}) do
        TodoList.add_entry(todo_list, entry)
    end
    defp into_callback(todo_list, :done), do: todo_list
    defp into_callback(todo_list, :halt), do: :ok
end

# entries = [
#     %{date: ~D[2018-12-19], title: "Dentist"},
#     %{date: ~D[2018-12-20], title: "Shopping"},
#     %{date: ~D[2018-12-19], title: "Movies"}
# ]
# for entry <- entries, into: TodoList.new(), do: entry
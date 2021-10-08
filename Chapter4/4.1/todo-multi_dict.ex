# Abstracting the underlying data type from the abstraction provides certain benefits.
# TodoList can add methods that aren't a part of MultiDict, like due_today/2
# which returns all entries for today.
# Another distinct MultiDict abstraction can be used elsewhere with other data types.

defmodule MultiDict do
    def new(), do: %{}

    def add(dict, key, value) do
        Map.update(dict, key, [value], &[value | &1])
    end

    def get(dict, key) do
        Map.get(dict, key, [])
    end
end

defmodule TodoList do
    def new(), do: MultiDict.new()

    def add_entry(todo_list, date, title) when is_date(date) do
        MultiDict.add(todo_list, date, title)
    end

    def entries(todo_list, date) when is_date(date) do
        MultiDict.get(todo_list, date)
    end
end

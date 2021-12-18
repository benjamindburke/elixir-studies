# Working with Hierarchical Data

# This module extends the TodoList from Section 4.2 withCSV import capabilities
# (4.2/todo-ids.ex)

defmodule TodoList do
    @doc "auto_id will contain the ID value assigned to the new entry"
    defstruct auto_id: 1, entries: %{}
    def new(entries \\ []) do
        Enum.reduce(
            entries,
            %TodoList{},
            &add_entry(&2, &1)
        )
    end
    def add_entry(todo_list, entry) do
        entry = Map.put(entry, :id, todo_list.auto_id)
        new_entries = Map.put(
            todo_list.entries,
            todo_list.auto_id,
            entry
        )
        %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
    end

    def entries(todo_list, date) do
        todo_list.entries()
        |> Stream.filter(fn {_, entry} -> entry.date == date end)
        |> Enum.map(fn {_, entry} -> entry end)
    end

    def update_entry(todo_list, entry_id, updater_fun) do
        case Map.fetch(todo_list.entries, entry_id) do
            :error -> todo_list
            {:ok, old_entry} ->
                old_entry_id = old_entry.id
                new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
                new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
                %TodoList{todo_list | entries: new_entries}
        end
    end

    def update_entry(todo_list, %{} = new_entry) do
        update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
    end

    def delete_entry(todo_list, id) do
        new_entries = Map.delete(todo_list.entries, id)
        %TodoList{todo_list | entries: new_entries}
    end
end

# todo_list = TodoList.new() |>
#     TodoList.add_entry(%{date: ~D[2018-12-19], title: "Dentist"}) |>
#     TodoList.add_entry(%{date: ~D[2018-12-20], title: "Shopping"}) |>
#     TodoList.add_entry(%{date: ~D[2018-12-19], title: "Movies"})

defmodule TodoList.CsvImporter do
    @todos "todos.csv"
    defp extract_entry([date|[title|[]]]) do
        [year, month, day] = String.split(date, "/") # Split the date at / separator
        year = String.to_integer(year) # Convert all to integers
        month = String.to_integer(month)
        day = String.to_integer(day)
        date = Date.new!(year, month, day)
        %{date: date, title: title}
    end
    def import(path \\ @todos) do
        File.stream!(path) # Read the file one line at a time
        |> Stream.map(&String.replace(&1, "\n", "")) # Remove all newline chars from line
        |> Stream.map(&String.split(&1, ",")) # Split the string at , separator
        |> Stream.map(&extract_entry(&1)) # extract one entry at a time
        |> TodoList.new()  # Pass final enumerable to the new/1 function
    end
end

# todos = TodoList.CsvImporter.import()
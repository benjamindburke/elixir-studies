
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
        |> Stream.filter(fn {_, entry} -> entry.date == date end) # Filters entries for a given date
        |> Enum.map(fn {_, entry} -> entry end) # Takes only values
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

    def delete_entry(todo_list, id), do: Map.delete(todo_list.entries, id)
end

defimpl Collectable, for: TodoList do
    def into(original) do
        {original, &into_callback/2}
    end

    defp into_callback(todo_list, {:cont, entry}) do
        TodoList.add_entry(todo_list, entry)
    end
    defp into_callback(todo_list, :done), do: todo_list
    defp into_callback(todo_list, :halt), do: :ok
end

defmodule TodoServer do
    def start, do: spawn(fn -> loop(TodoList.new()) end) # use a new TodoList as the initial state

    defp loop(todo_list) do
        new_todo_list =
            receive do
                message -> process_message(todo_list, message)
            end

        loop(new_todo_list)
    end

    defp process_message(todo_list, {:add_entry, new_entry}) do
        TodoList.add_entry(todo_list, new_entry)
    end

    defp process_message(todo_list, {:entries, caller, date}) do
        send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    end

    defp process_message(todo_list, {:delete_entry, id}) do
        TodoList.delete_entry(todo_list, id)
    end

    defp process_message(todo_list, {:update_entry, %{} = new_entry}) do
        TodoList.update_entry(todo_list, new_entry)
    end

    def add_entry(todo_server, new_entry) do
        send(todo_server, {:add_entry, new_entry})
    end

    def entries(todo_server, date) do
        send(todo_server, {:entries, self(), date})

        receive do
            {:todo_entries, entries} -> entries
        after
            5000 -> {:error, :timeout}
        end
    end

    def delete_entry(todo_server, id) do
        send(todo_server, {:delete_entry, id})
    end
end

# todo_server = TodoServer.start()
# entries = [
#     %{date: ~D[2018-12-19], title: "Dentist"},
#     %{date: ~D[2018-12-20], title: "Shopping"},
#     %{date: ~D[2018-12-19], title: "Movies"}
# ]
# todo_list = for entry <- entries, into: TodoList.new(), do: &TodoServer.add_entry(todo_server, &1)

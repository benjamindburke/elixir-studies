defmodule Todo.List do
  @doc "auto_id will contain the ID value assigned to the new entry"
  defstruct auto_id: 1, entries: %{}

  def new(entries) do
    Enum.reduce(
      entries,
      %Todo.List{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)
    %Todo.List{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  def entries(todo_list, %Date{} = date) do
    todo_list.entries()
    |> Stream.filter(fn {_, entry} -> entry.date == date end) # Filters entries for a given date
    |> Enum.map(fn {_, entry} -> entry end) # Takes only values
  end

  def entries(todo_list, title) when is_binary(title) do
    todo_list.entries()
    |> Stream.filter(fn {_, entry} -> entry.title == title end) # Filters entries for a given date
    |> Enum.map(fn {_, entry} -> entry end) # Takes only values
  end

  def entries(todo_list, id) when is_integer(id) do
    Map.get(todo_list.entries, id)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    # TODO : when updating an entry, why is the entire entry overwritten and the two don't merge?
    case Map.fetch(todo_list.entries, entry_id) do
      :error -> todo_list
      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, Map.merge(new_entry, todo_list.entries[new_entry.id], fn _k, v1, _v2 -> v1 end))
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def delete_entry(todo_list, id) do
    new_entries = Map.delete(todo_list.entries, id)
    %Todo.List{todo_list | entries: new_entries}
  end
end

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

# TEST CODE
# ---------

# entries = [
#     %{date: ~D[2018-12-19], title: "Dentist"},
#     %{date: ~D[2018-12-20], title: "Shopping"},
#     %{date: ~D[2018-12-19], title: "Movies"}
# ]
# Todo.Server.start(entries)
# Todo.Server.entries(~D[2018-12-19])
# Todo.Server.entries(1)
# Todo.Server.update_entry(%{id: 2, title: "Feeding Pesto"})
# Todo.Server.add_entry(%{date: ~D[2021-11-08], title: "Feeding Pesto"})
# Todo.Server.entries("Feeding Pesto")
# Todo.Server.delete_entry(4)
# Todo.Server.entries(1)
# Todo.Server.entries("Feeding Pesto")

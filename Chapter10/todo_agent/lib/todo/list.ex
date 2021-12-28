# Todo List [struct]
# Data structure containing interfaces to manipulate and query to-do list entries
defmodule Todo.List do
  defstruct auto_id: 1, entries: %{}

  # ---------
  # Interface functions
  # ---------

  def new(entries) do
    Enum.reduce(
      entries,
      %Todo.List{},
      &add_entry(&2, &1)
    )
  end

  # CREATE
  # ---------
  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)
    %Todo.List{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  # READ
  # ---------
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

  # UPDATE
  # ---------
  def update_entry(todo_list, entry_id, updater_fun) do
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

  # DELETE
  # ---------
  def delete_entry(todo_list, id) do
    new_entries = Map.delete(todo_list.entries, id)
    %Todo.List{todo_list | entries: new_entries}
  end
end

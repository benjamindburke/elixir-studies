# Working with Hierarchical Data

# This module extends the TodoList from Section 4.1 with basic CRUD support
# (4.1/Struct.ex)


defmodule TodoList do
    @doc "auto_id will contain the ID value assigned to the new entry"
    defstruct auto_id: 1, entries: %{}
    def new(entries \\ []) do
        Enum.reduce(
            entries,
            %TodoList{}, # initial accumulator value
            # reverse the order of args given by reducer fun (entry, accum ->)
            &add_entry(&2, &1) # iteratively update the accumulator
        )
    end

    # To the external caller, all operations will be entirely atomic
    # Either everything will happen or, in the case of an error, nothing at all.
    # The effect of adding an entry is visible to others only when the add_entry/2 function finishes
    # and the result is taken into a variable
    # The resulting TodoList will share as much memory with the original as possible
    def add_entry(todo_list, entry) do
        # sets the new entry's ID
        # must first update the entry's id value with the value stored in the auto_id field
        # the input map may not contain the id field, so we can't use standard map update syntax
        # ex: %{entry | id: auto_id}
        entry = Map.put(entry, :id, todo_list.auto_id)
        # Adds the new entry to the entries list once the entry is updated
        new_entries = Map.put(
            todo_list.entries,
            todo_list.auto_id,
            entry
        )
        # update the struct
        # setting the entries field to the new_entries collection and incrementing the auto_id field
        %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
    end

    # Now that the internal data structure has changed,
    # we need to iterate through all entries to find the ones falling on certain dates
    # This function takes advantage of the fact that a map is an enumerable
    # When using a map instance with functions from Enum or Stream,
    # each map element is treated in the form of {key, value}
    def entries(todo_list, date) do
        todo_list.entries()
        |> Stream.filter(fn {_, entry} -> entry.date == date end) # Filters entries for a given date
        |> Enum.map(fn {_, entry} -> entry end) # Takes only values
    end

    # There are two ways to update this data structure
    # 1. The function will accept and ID and an updater lambda and will work like Map.update
    # 2. The function will accept and entry map and replace the present one if the ID exists in the current map
    # Questions: what should the function do if the ID doesn't exist?
    # Example usage:
    #   TodoList.update_entry(todo_list, 1, &Map.put(&1, :date, ~D[2018-12-20]))
    def update_entry(todo_list, entry_id, updater_fun) do
        # Map.fetch will return :error if the entry doesn't exist
        # or it will return {:ok, value} if the entry exists
        case Map.fetch(todo_list.entries, entry_id) do
            # No entry, return the unchanged list
            :error -> todo_list
            # Entry exists - performs the update and returns the modified list
            {:ok, old_entry} ->
                # perform some pattern matching to prevent the lambda (which can return any type)
                # from corrupting the data structure
                # require the lambda return type to be a map (nested pattern match)
                # and require the ID has not been changed
                # ^ requires matching the value of the variable
                old_entry_id = old_entry.id
                new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
                new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
                %TodoList{todo_list | entries: new_entries}
        end
    end

    # Here we create an update_entry/2 which delegates to update_entry/3
    # And pattern matching expects a TodoList with a new map entry
    def update_entry(todo_list, %{} = new_entry) do
        update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
    end

    def delete_entry(todo_list, id) do
        new_entries = Map.delete(todo_list.entries, id)
        %TodoList{todo_list | entries: new_entries}
    end
end

# Example of using the Kernel.put_in macro to deeply update the hierarchy:
# put_in(todo_list[3].title, "Theater")
# This approach is evaluated at compile time, so the path to the update can't be dynamically computed
# However, if you need to construct paths at runtime, the Kernel.put_in/3 macro is available
# path = [3, title]
# put_in(todo_list, path, "Theater")

# test object
todo_list = TodoList.new() |>
    TodoList.add_entry(%{date: ~D[2018-12-19], title: "Dentist"}) |>
    TodoList.add_entry(%{date: ~D[2018-12-20], title: "Shopping"}) |>
    TodoList.add_entry(%{date: ~D[2018-12-19], title: "Movies"})
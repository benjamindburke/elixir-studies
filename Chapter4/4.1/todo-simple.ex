# Let's make a to-do list.

# The To-Do list will support the following features:
# 1. creating a new data abstraction
# 2. Adding new entries
# 3. Querying the abstraction

# Example of desired usage:

# todo_list =
#   TodoList.new()
#   |> TodoList.add_entry(~D[2021-12-19], "Dentist")
#   |> TodoList.add_entry(~D[2021-12-20], "Shopping")
#   |> TodoList.add_entry(~D[2021-12-19], "Movies")

# TodoList.entries(todo_list, ~D[2021-12-19]) # returns ["Movies", "Dentist"]
# TodoList.entries(todo_list, ~D[2021-12-18]) # returns []

defmodule TodoList do
    # Create a new abstraction
    def new(), do: %{}

    # The Map.update/4 function receives a map, key, initial value, and an updater lambda.
    # If no value exists for the given key, the initial value is used.
    # Otherwise, the updater lambda is called.
    # The lambda receives the existing value (titles) and returns the new value for that key
    # Remember, as dicussed in Chapter 2 lists are most efficient when used as FIFO queues
    def add_entry(todo_list, date, title) do
        Map.update(
            todo_list,
            date,
            [title], # initial value
            fn titles -> [title | titles] end # updater lambda
        )
    end

    # Query function entries/2
    def entries(todo_list, date) do
        Map.get(
            todo_list,
            date,
            [] # default value
        )
    end
end
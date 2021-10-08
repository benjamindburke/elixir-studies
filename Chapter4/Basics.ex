# The basic principles of data abstraction in Elixir are as follows:

# 1. A module is in charge of abstracting some data
# 2. The module's functions usually expect an instance of the data abstraction as the first argument
# 3. Modifier functions return a modified version of the abstraction
# 4. Query functions return some other type of data

# Let's inspect the MapSet module which is a higher-level data abstraction.
# The MapSet module implements a set

days = MapSet.new()
    |> MapSet.put(:monday)
    |> MapSet.put(:tuesday)

MapSet.member?(days, :monday) # returns true

# Notice the new/0 function that creates an empty instance of the abstraction.
# There's nothing special about this function.
# Its only purpose is to create an empty data structure you can then work on

# Module base abstractions aren't proper data types like the ones explained in Chapter 2.
# Instead, they're implemented by composing built-in datta tpes.
# For example, a MapSet instance is also a map, which can be verified by invoking:
is_map(MapSet.new())

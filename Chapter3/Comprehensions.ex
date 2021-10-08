# Comprehensions are a special syntax for iterating through enumerables.


# The following example uses a comprehension to square each element of a list:

for x <- [1,2,3] do
    x*x
end

# The result is a list containing all the results returned by the do/end block.
# In this form, `for` is no different than Enum.map/2

# Comprehensions have various other features that often make them elegant
# compared to Enum-based iterations.
# For example, it's possible to perform nested iterations over multiple iterables:

for x <- [1,2,3], y <- [1,2,3], do: {x, y, x*y}

for x <- 1..9, y <- 1..9, do: {x, y, x*y}

# Comprehensions can return anything that's collectable.
# _Collectable_ is an abstract term for a functional data type that can collect values.

# For example, here's a map that holds a multiplication table.
# The keys are tuples of factors {x,y} and the values contain products:

multiplication_table =
    for x <- 1..9, y <- 1..9,
        # construct a new map to store values "into: %{}"
        # key/value pairs "{key, value}"
        into: %{} do
        {{x, y}, {x*y}}
    end

multiplication_table[{7,6}] # returns 42

# The {key, value} tuple format is something that the new map knows how to interpret.
# %{} is the collectable which adds the new key/value pairs.

# Comprehensions can also specify filters. This allows you to skip some items within the iterable.
# The comprehension filter is evaluated for each element of the input enumerable prior to block execution.
# If the filter returns true, the block is called and the result is collected.

# For example, let's compute a nonsymmetrical multiplication table
# for numbers x and y, where x is never greater than y:

multiplication_table2 =
    for x <- 1..9, y <- 1..9,
        x <= y,
        into: %{} do
        {{x, y}, x * y}
    end

multiplication_table2[{6, 7}] # returns 42
multiplication_table2[{7,6}] # returns nil


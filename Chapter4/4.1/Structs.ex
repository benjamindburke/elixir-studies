# In some situations, you may want to define and enforce a more precise structure definition.
# For surc cases, Elixir provides a feature called structs.

# Example of the Fraction module being called:
# Fraction.add(Fraction.new(1, 2), Fraction.new(1, 4))
#   |> Fraction.value() # returns 0.75

# Notice that there's no notion of how the faction is represented.
# A client instantiates the abstraction and passes it
# on to another functions from the corresponding module.

# Elixir provides a feature called structs that allows you to
# spceify the abstraction structure up front and bind it to a module.
# Each module can define only one struct, which can then be used to create new instances and pattern-match on them.

defmodule Fraction do
    defstruct a: nil, b: nil
    def new(a, b) do
        %Fraction{a: a, b: b}
    end
    def value(%Fraction{a: a, b: b}) do
        a / b
    end
    # can also specify slightly more readable version,
    # with minor performance drawbacks:
    # def value(fraction) do
    #   fraction.a / fraction.b
    # end
    def add(%Fraction{a: a1, b: b1}, %Fraction{a: a2, b: b2}) do
        new(
            a1 * b2 + a2 * b1,
            b2 * b1
        )
    end
end


# one_half = %Fraction{a: 1, b: 2}

# Underneath, a struct instance is a special kind of map:

# one_half.a # returns 1
# one_half.b # returns 2

# Pattern matching works on structs:

# %Fraction{a: a, b: b} = one_half
# a # returns 1
# b # returns 2

# This makes it possible to assert that some variable is really a struct:
# %Fraction{} = one_half # successful match
# %Fraction{} = %{a: 1, b: 2} # returns MatchError because a struct pattern doesn't match a map

# Updating a struct works similarly to the way it works with maps:

# one_quarter = %Fraction{one_half | b: 4 }
# one_quarter # returns %Fraction{a: 1, b: 4}

# Fraction.add(Fraction.new(1, 2), Fraction.new(1, 4)) |> Fraction.value() # returns 0.75

# Structs vs. Maps

# Structs are in reality just maps, so they have the same characteristics
# with respect to performance and memory usage.
# But a struct instance receives special treatment.
# Some things that can be done with maps don't work with structs.

# For example, you can't call the Enum function on a struct:
# one_half = Fraction.new(1, 2)
# Enum.to_list(one_half) # (ProtocolError) protocol Enumerable not implemented for %Fraction{a: 1, b: 2}

# A struct is a functional abstraction and should therefore behave according
# to the implementation of the module where it's defined.
# In the case of the Fraction abstraction,
# you must define where Fraction is enumerable, # and if so, in what way.

# If this isn't done, Fraction isn't an enumerable, so you can't call Enum functions on it.
# On the other hand, because structs are maps, directly calling Map functions works:

# Map.to_list(one_half) # returns [__struct__: Fraction, a: 1, b: 2]

# The __struct__ key value pair is automatically included in each struct.
# It helps Elixir distinguish from plain maps and perform proper runtime dispatches from within polymorphic generic code.

# A struct pattern can't match a plain map:

# %Fraction{} = %{a: 1, b: 2}

# But a plain map pattern can match a struct:
# %{a: a, b: b} = %Fraction{a: 1, b: 2}
# Polymorphism is a runtime decision about which code to execute, based on the nature of the input data.
# For example, the entire Enum module is generic code that works on anything enumerable
# This works because each data type that can be passed to the Enum module has the enumeration protocl defined

# A protocol is a module in which you declare functions without implementing them

# Consider it the rough equivalent of the OO interface. The generic logic relies on the protocol and calls its functions
# The protocol String.Chars is user to conver data to a binary string
# And Kernel.to_string() relies on the String.Chars implementation via delegation

# Example: the implementation of the String.Chars protocol for integers
# defimpl String.Chars, for: Integer do
#     def to_string(term) do
#         Integer.to_string(term)
#     end
# end

# The for: Type is can be used with the Elixir built-in types:
# Tuple, Atom, List, Map, BitString, Integer, Float, Function, PID, Port, or Reference
# In addition, the Any alias is allowed, which makes it possible to specify a fallback implementation
# Most importantly, the type can be any other arbitrary alias (but not a regular simple atom)

defimpl String.Chars, for: TodoList do
    def to_string(_) do
        "#TodoList"
    end
end

# These protocol implementations don't need to be a part of any module.
# This means, a protocol can be implemented for a type even if the type's source code can't be modified
# A protocol implementation can be placed anywhere in the code, and the runtime can take advantage of it

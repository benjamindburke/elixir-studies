# two ways to define non-anonymous functions
# multi-line
defmodule Geometry do
  def rectangle_area(l, w) do
    l * w
  end
  def circle_area(r) do
    r * 3.14 * r
  end

  # can omit the module prefix if function in same module
  def triangle_area(b, h) do
    rectangle_area(b, h) / 2
  end
end

# one-liners
# arity - the number of arguments a function receives
# think of "overloaded" functions as distinct from one another because arity differs
defmodule Rectangle do
  # Rectangle.area/1 - "/1" denotes arity 1
  # (or 1 argument)
  # NOTE : do not forget the comma separating function def from "do:" macro
  def area(a), do: area(a, a)

  # Rectangle.area/2 - "/2" denotes arity 2
  # (or 2 arguments)
  # NOTE : do not forget the comma separating function def from "do:" macro
  # cannot omit the module prefix here since function in different module
  def area(a, b), do: Geometry.rectangle_area(a, b)
end

defmodule Print do
  # test the pipe operator
  # returns ":ok" because that's what the last line (IO.puts) returns
  # pipe operator sends function's return to next function as first argument
  def format_abs(a) do
    a
      |> abs()
      |> Integer.to_string()
      |> IO.puts()
  end
end

# since functions of different arity-ies are distinct
# there is no equivalent of JavaScript `arguments` internal
# therefore it is not possible to create functions with variable number of arguments
defmodule Calculator do
  # sum/1 and sum/2 equivalent to sum(a, b \\ 0), do: a + b
  def sum(a), do: sum(a, 0) # Calculator.sum/1 delegates to Calculator.sum/2
  def sum(a, b), do: a + b  # Calculator.sum/2 contains the implementation

  # specifying default values creates a version of the function for each arity
  # equivalent to creating sum/1, sum/2, sum/3, and sum/4 for all args
  def sum_all(a, b \\ 0, c \\ 0, d \\ 0), do
    a + b + c + d
  end
end

# functions created using "def" are automatically exported
# functions created using "defp" are created as private functions
defmodule TestPrivate do
  # automatically exposed or "exported"
  def double(a), do
    sum(a, a)
  end
  # not exposed, will throw UndefinedFunctionError if called externally
  defp sum(a, b), do
    a + b
  end
end

# importing functions
# Kernel module is automatically imported to every Elixir module
defmodule MyModule do
  # allows us to remove the IO prefix from functions
  import IO

  # NOTE : remember that function calls do not require parentheses
  def my_function(), do
    puts "Calling imported function."
  end
end

# alias module names so name conflicts do not arise
# this is also very useful for renaming long module hierarchies with better contextual names
# i.e. `alias Geometry.Rectangle, as: Rectangle`
# but Elixir can do this better - `alias Geometry.Rectangle` (omit "do:") is equivalent!
defmodule AliasModule do
  alias IO, as: MyIO

  # NOTE : remember that function calls do not require parentheses
  def my_function() do
    MyIO.puts "Calling imported function."
  end
end

# module attributes
# @doc and @moduledoc provide documentation for functions and modules, respectively
# registered attributes ("@") only exist during the compilation of the module
# to compile, `elixirc <filename>.ex` in CLI
# in an interactive session:
# call `Code.fetch_docs(Circle)` to get all docs
# or `h Circle` for module docs
# or `h Circle.area` for function docs
# erlang tool "ex_doc" can help with creating documentation in HTML format for large projects

# type specifications with @spec
# can later be analyzed using a static analysis tool call "dialyzer"
# detailed info on types can be found at https://hexdocs.pm/elixir/typespecs.html
defmodule Circle do
  @moduledoc "Implements basic Circle functions"

  # specify a pi variable that can be reused across functions
  @pi 3.14159

  @doc "Computes the area of a circle"
  @spec area(number) :: number
  def area(r), do: r * r * @pi

  @doc "Computes the circumference of a circle"
  @spec circumference(number) :: number
  def circumference(r), do: 2 * r * @pi
end


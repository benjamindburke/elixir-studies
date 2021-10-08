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
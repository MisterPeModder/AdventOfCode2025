defmodule AdventOfCodeRunner.SolutionInfo do
  @enforce_keys [:year, :day]
  defstruct [:year, :day]
  @type t :: %__MODULE__{}
end

defmodule AdventOfCodeRunner.Solution do
  alias AdventOfCodeRunner.SolutionInfo

  @type solution :: pid()
  @type data :: term()
  @type result :: integer()

  @callback setup(String.t()) :: {:ok, data()} | {:error, term}
  @callback part1(data()) :: result()
  @callback part2(data()) :: result()

  defmacro __using__(args) when is_list(args) do
    info = %SolutionInfo{
      year: Keyword.fetch!(args, :year),
      day: Keyword.fetch!(args, :day)
    }

    quote do
      @behaviour AdventOfCodeRunner.Solution

      def info(), do: unquote(Macro.escape(info))

      def setup(input), do: {:ok, input}
      defoverridable setup: 1

      def part1(input)

      def part2(input)
    end
  end

  @spec info(module) :: SolutionInfo.t()
  def info(module) do
    module.info()
  end

  @spec setup(solution(), term()) :: {:ok, data()} | {:error, atom()}
  def setup(solution, input) do
    try do
      case solution.setup(input) do
        {:ok, transformed} -> {:ok, transformed}
        {:error, _} = error -> error
      end
    rescue
      error -> {:error, error}
    end
  end

  @spec setup(solution(), term()) :: {:ok, result()} | {:error, atom()}
  def part1(solution, transformed_input) do
    try do
      case solution.part1(transformed_input) do
        result when is_integer(result) -> {:ok, result}
        _ -> {:error, :bad_result}
      end
    rescue
      error -> {:error, error}
    end
  end

  @spec setup(solution(), term()) :: {:ok, result()} | {:error, atom()}
  def part2(solution, transformed_input) do
    try do
      case solution.part2(transformed_input) do
        result when is_integer(result) -> {:ok, result}
        _ -> {:error, :bad_result}
      end
    rescue
      error -> {:error, error}
    end
  end
end

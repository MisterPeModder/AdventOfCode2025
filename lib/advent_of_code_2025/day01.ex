defmodule AdventOfCode2025.Day01 do
  use AdventOfCodeRunner.Solution, year: 2025, day: 1

  @type side :: 1 | -1
  @type rotation :: {side :: side(), distance :: pos_integer()}
  @type state :: {pos :: non_neg_integer(), count :: non_neg_integer()}

  @impl true
  @spec setup(String.t()) :: {:ok, list(rotation())}
  def setup(input) do
    sequence =
      input
      |> String.split()
      |> Enum.map(&parse_rotation/1)

    {:ok, sequence}
  end

  @impl true
  @spec part1(data :: list({integer(), pos_integer()})) :: integer()
  def part1(data) do
    for {side, distance} <- data, reduce: {50, 0} do
      acc -> rotate(side * distance, acc)
    end
    |> elem(1)
  end

  @impl true
  @spec part2(data :: list({integer(), pos_integer()})) :: integer()
  def part2(data) do
    for {side, distance} <- data, unit <- List.duplicate(side, distance), reduce: {50, 0} do
      acc -> rotate(unit, acc)
    end
    |> elem(1)
  end

  @spec parse_rotation(String.t()) :: rotation()
  defp parse_rotation(line) do
    {side, d} =
      case line do
        <<?R::utf8, d::binary>> -> {+1, d}
        <<?L::utf8, d::binary>> -> {-1, d}
      end

    with {distance, _} <- Integer.parse(d) do
      {side, distance}
    end
  end

  @spec rotate(distance :: pos_integer(), acc :: state()) :: state()
  defp rotate(distance, {pos, count}) do
    case Integer.mod(pos + distance, 100) do
      0 -> {0, count + 1}
      new_pos -> {new_pos, count}
    end
  end
end

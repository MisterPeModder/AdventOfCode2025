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
    Enum.reduce(data, {50, 0}, fn {side, distance}, acc -> rotate(side * distance, acc) end)
    |> elem(1)
  end

  @impl true
  @spec part2(data :: list({integer(), pos_integer()})) :: integer()
  def part2(data) do
    data
    |> Stream.flat_map(&to_unit_rotations/1)
    |> Enum.reduce({50, 0}, &rotate/2)
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

  @spec to_unit_rotations(rotation()) :: list(side())
  defp to_unit_rotations({side, distance}) do
    Stream.repeatedly(fn -> side end) |> Enum.take(distance)
  end
end

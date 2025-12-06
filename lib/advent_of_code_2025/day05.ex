defmodule AdventOfCode2025.Day05 do
  use AdventOfCodeRunner.Solution

  @impl true
  @spec setup(String.t()) :: {:ok, {list(Range.t()), list(pos_integer())}}
  def setup(input) do
    {ranges, items} = input |> String.split("\n") |> Enum.split_while(fn line -> line != "" end)

    ranges =
      Enum.map(ranges, fn range ->
        [first | [last | _]] = String.split(range, "-")
        {first, _} = Integer.parse(first)
        {last, _} = Integer.parse(last)
        first..last
      end)

    items =
      items
      |> Enum.reject(&match?("", &1))
      |> Enum.map(fn item -> Integer.parse(item) |> elem(0) end)

    {:ok, {ranges, items}}
  end

  @impl true
  def part1({ranges, items}) do
    ranges = normalize_ranges(ranges)

    items
    |> Enum.count(fn item -> Enum.any?(ranges, fn range -> item in range end) end)
  end

  @impl true
  def part2({ranges, _}) do
    ranges
    |> normalize_ranges()
    |> Enum.map(fn %Range{first: first, last: last} -> last + 1 - first end)
    |> Enum.sum()
  end

  def normalize_ranges(ranges) do
    ranges
    |> Enum.sort_by(fn %Range{first: first} -> first end)
    |> List.foldl([], fn
      range, [] ->
        [range]

      range, [head | tail] = merged ->
        if Range.disjoint?(range, head) do
          [range | merged]
        else
          [min(range.first, head.first)..max(range.last, head.last) | tail]
        end
    end)
  end
end

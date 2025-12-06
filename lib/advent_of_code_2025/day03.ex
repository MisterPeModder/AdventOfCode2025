defmodule AdventOfCode2025.Day03 do
  use AdventOfCodeRunner.Solution

  @impl true
  @spec setup(String.t()) :: {:ok, list(list(pos_integer()))}
  def setup(input) do
    batteries =
      for battery <- String.split(input, "\n"), battery != "" do
        for <<digit <- battery>> do
          digit - ?0
        end
      end

    {:ok, batteries}
  end

  @spec part1(list(list(pos_integer()))) :: pos_integer()
  @impl true
  def part1(data) do
    data
    |> Enum.map(&highest(2, &1))
    |> Enum.sum()
  end

  @spec part1(list(list(pos_integer()))) :: pos_integer()
  @impl true
  def part2(data) do
    data
    |> Enum.map(&highest(12, &1))
    |> Enum.sum()
  end

  @spec highest(pos_integer(), list(pos_integer())) :: pos_integer()
  def highest(size, battery) do
    [high | rest] = find_start(size, battery)

    if size == 2 do
      high * 10 + Enum.max(rest)
    else
      high * 10 ** (size - 1) + highest(size - 1, rest)
    end
  end

  @spec find_start(pos_integer(), list(pos_integer())) :: list(pos_integer())
  def find_start(size, battery) when length(battery) < size, do: [0]

  def find_start(size, [f | rest] = battery) do
    case find_start(size, rest) do
      [s | _] = x when s > f -> x
      _ -> battery
    end
  end
end

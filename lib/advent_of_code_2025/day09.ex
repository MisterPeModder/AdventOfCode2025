defmodule AdventOfCode2025.Day09 do
  use AdventOfCodeRunner.Solution

  @impl true
  def setup(input) do
    tiles =
      String.split(input, "\n")
      |> Enum.reject(&match?("", &1))
      |> Enum.map(fn line ->
        [col | [row | _]] = String.split(line, ",")
        {col, _} = Integer.parse(col)
        {row, _} = Integer.parse(row)
        {row, col}
      end)

    {:ok, tiles}
  end

  @impl true
  def part1(tiles) do
    pairs = for t1 <- tiles, t2 <- tiles, cmp(t1, t2) < 0, do: {t1, t2}
    pair = Enum.max_by(pairs, &area/1)
    area(pair)
  end

  @impl true
  def part2(_tiles) do
    0
  end

  defp cmp({row_1, col_1}, {row_2, col_2}) do
    1_000_000 * row_1 + col_1 - (1_000_000 * row_2 + col_2)
  end

  defp area({{row_1, col_1}, {row_2, col_2}}) do
    (abs(row_1 - row_2) + 1) * (abs(col_1 - col_2) + 1)
  end
end

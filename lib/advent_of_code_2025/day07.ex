defmodule AdventOfCode2025.Day07 do
  use AdventOfCodeRunner.Solution

  @impl true
  @spec setup(String.t()) ::
          {:ok, {pos_integer(), pos_integer(), MapSet.t({non_neg_integer(), non_neg_integer()})}}
  def setup(input) do
    [first | _] = lines = String.split(input, "\n") |> Enum.reject(&match?("", &1))

    {start, _} = :binary.match(first, "S")
    height = length(lines)

    splitters =
      for {line, row} <- Enum.with_index(lines),
          {c, col} <- Enum.with_index(String.to_charlist(line)),
          c == ?^,
          into: MapSet.new() do
        {row, col}
      end

    {:ok, {start, height, splitters}}
  end

  @impl true
  def part1({start, height, splitters}) do
    {_, split_count} =
      for _i <- 2..height, reduce: {[{0, start}], 0} do
        {beams, split_count} -> bfs(beams, splitters, split_count)
      end

    split_count
  end

  @impl true
  def part2({start, height, splitters}) do
    {timelines, _cache} = dfs(0, start, splitters, height, Map.new())
    timelines
  end

  def bfs(beams, splitters, split_count) do
    {next_beams, split_count} =
      Enum.flat_map_reduce(beams, split_count, fn {b_row, b_col}, split_count ->
        down = {b_row + 1, b_col}

        if MapSet.member?(splitters, down) do
          {[{b_row + 1, b_col - 1}, {b_row + 1, b_col + 1}], split_count + 1}
        else
          {[down], split_count}
        end
      end)

    {Enum.dedup(next_beams), split_count}
  end

  def dfs(row, _col, _splitters, height, cache) when row >= height,
    do: {1, cache}

  def dfs(row, col, splitters, height, cache) do
    case Map.get(cache, {row, col}) do
      nil ->
        {timelines, cache} =
          if MapSet.member?(splitters, {row + 1, col}) do
            {tl_left, cache} = dfs(row + 1, col - 1, splitters, height, cache)
            {tl_right, cache} = dfs(row + 1, col + 1, splitters, height, cache)
            {tl_left + tl_right, cache}
          else
            dfs(row + 1, col, splitters, height, cache)
          end

        {timelines, Map.put(cache, {row, col}, timelines)}

      cached ->
        {cached, cache}
    end
  end
end

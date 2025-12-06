defmodule AdventOfCode2025.Day04 do
  use AdventOfCodeRunner.Solution

  @impl true
  @spec setup(String.t()) :: {:ok, {pos_integer(), pos_integer(), MapSet.t()}}
  def setup(input) do
    [first | _] = lines = String.split(input, "\n") |> Enum.reject(&match?("", &1))

    width = byte_size(first)
    height = length(lines)

    at_positions =
      for {line, row} <- Enum.with_index(lines),
          {c, col} <- Enum.with_index(String.to_charlist(line)),
          c == ?@,
          into: MapSet.new() do
        {row, col}
      end

    {:ok, {width, height, at_positions}}
  end

  @impl true
  def part1({width, height, at_positions}) do
    for row <- 0..(height - 1),
        col <- 0..(width - 1),
        MapSet.member?(at_positions, {row, col}) and accessible?(at_positions, row, col),
        reduce: 0 do
      sum -> sum + 1
    end
  end

  @impl true
  def part2({width, height, at_positions}) do
    {_, deleted} =
      for row <- 0..(height - 1), col <- 0..(width - 1), reduce: {at_positions, 0} do
        acc -> remove_accessible(acc, row, col)
      end

    deleted
  end

  @offsets [{-1, -1}, {-1, 0}, {-1, +1}, {0, +1}, {+1, +1}, {+1, 0}, {+1, -1}, {0, -1}]

  defp count_neighbors(at_positions, row, col) do
    Enum.reduce_while(@offsets, 0, fn {y, x}, count ->
      cond do
        count >= 4 -> {:halt, count}
        MapSet.member?(at_positions, {row + y, col + x}) -> {:cont, count + 1}
        true -> {:cont, count}
      end
    end)
  end

  defp accessible?(at_positions, row, col) do
    count_neighbors(at_positions, row, col) < 4
  end

  defp remove_accessible({at_positions, deleted}, row, col) do
    cond do
      not MapSet.member?(at_positions, {row, col}) ->
        {at_positions, deleted}

      accessible?(at_positions, row, col) ->
        acc = {MapSet.delete(at_positions, {row, col}), deleted + 1}

        Enum.reduce(@offsets, acc, fn {y, x}, {pos, deleted} ->
          remove_accessible({pos, deleted}, row + y, col + x)
        end)

      true ->
        {at_positions, deleted}
    end
  end
end

defmodule AdventOfCode2025.Day02 do
  use AdventOfCodeRunner.Solution

  @impl true
  @spec setup(String.t()) :: {:ok, list(Range.t())}
  def setup(input) do
    ranges =
      for range <- String.split(input, ",") do
        [first | [last | _]] = String.split(range, "-")
        {first, _} = Integer.parse(first)
        {last, _} = Integer.parse(last)
        first..last
      end

    {:ok, ranges}
  end

  @impl true
  @spec part1(data :: list(Range.t())) :: integer()
  def part1(data) do
    for range <- data, id <- range, reduce: 0 do
      sum -> if valid_id_x?(id, count_digits(id), 2), do: sum, else: sum + id
    end
  end

  @impl true
  @spec part1(data :: list(Range.t())) :: integer()
  def part2(data) do
    for range <- data, id <- range, reduce: 0 do
      sum -> if valid_id?(id), do: sum, else: sum + id
    end
  end

  @spec valid_id?(pos_integer()) :: pos_integer()
  defp count_digits(n) do
    ceil(:math.log10(n))
  end

  @spec valid_id?(pos_integer()) :: boolean()
  defp valid_id?(id) do
    n_digits = floor(:math.log10(id) + 1)

    Enum.all?(1..n_digits, &valid_id_x?(id, n_digits, &1))
  end

  @spec valid_id_x?(pos_integer(), pos_integer(), pos_integer()) :: boolean()
  defp valid_id_x?(_id, _n_digits, 1), do: true
  defp valid_id_x?(_id, n_digits, x) when rem(n_digits, x) != 0, do: true

  defp valid_id_x?(id, n_digits, n_parts) do
    pow = 10 ** div(n_digits, n_parts)
    seq = rem(id, pow)
    y = Enum.reduce(1..n_parts, 0, fn _, acc -> acc * pow + seq end)
    id != y
  end
end

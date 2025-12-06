defmodule AdventOfCode2025.Day06 do
  use AdventOfCodeRunner.Solution

  @impl true
  @spec setup(String.t()) :: {:ok, {list(Range.t()), list(pos_integer())}}
  def setup(input) do
    data =
      input
      |> String.split("\n")
      |> Enum.reject(&match?("", &1))

    {:ok, data}
  end

  @impl true
  def part1(data) do
    data
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.zip()
    |> Enum.map(fn
      {a, b, c, d, "+"} -> {[parse(a), parse(b), parse(c), parse(d)], :+}
      {a, b, c, d, "*"} -> {[parse(a), parse(b), parse(c), parse(d)], :*}
    end)
    |> run_operations()
  end

  @impl true
  def part2(data) do
    {lines, ops} = Enum.split(data, length(data) - 1)
    max_len = Enum.max_by(data, &byte_size/1) |> byte_size()

    ops =
      hd(ops)
      |> String.split(" ", trim: true)
      |> Enum.reverse()
      |> Enum.map(fn
        "+" -> :+
        "*" -> :*
      end)

    # convert rows to columns
    transposed =
      for col <- (max_len - 1)..0//-1 do
        for line <- lines, into: <<>> do
          case String.at(line, col) do
            nil -> " "
            c -> c
          end
        end
      end

    chunked =
      Enum.chunk_while(
        transposed,
        [],
        fn e, acc ->
          if String.trim(e) == "", do: {:cont, acc, []}, else: {:cont, [parse_sp(e) | acc]}
        end,
        fn acc -> {:cont, acc, []} end
      )
      |> Enum.zip(ops)

    run_operations(chunked)
  end

  def parse(n) do
    {res, _} = Integer.parse(n)
    res
  end

  def parse_sp(str) do
    for <<d <- str>>, reduce: 0 do
      acc ->
        case d do
          ?\s -> acc
          d -> acc * 10 + (d - ?0)
        end
    end
  end

  def run_operations(ops) do
    Enum.map(ops, fn
      {nums, :+} -> Enum.sum(nums)
      {nums, :*} -> Enum.product(nums)
    end)
    |> Enum.sum()
  end
end

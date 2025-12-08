defmodule AdventOfCode2025.Day08 do
  use AdventOfCodeRunner.Solution

  @impl true
  def setup(input) do
    junctions =
      String.split(input, "\n")
      |> Enum.reject(&match?("", &1))
      |> Enum.map(fn line ->
        [x, y, z] = String.split(line, ",")
        {parse(x), parse(y), parse(z)}
      end)

    {:ok, junctions}
  end

  @impl true
  def part1(junctions) do
    pairs = for j1 <- junctions, j2 <- junctions, j1 != j2, do: {j1, j2}

    pairs =
      pairs
      |> Enum.sort_by(fn {j1, j2} -> distance(j1, j2) end)
      |> Enum.take_every(2)
      |> Enum.reduce_while({MapSet.new(), 1000}, fn pair, {conn, n} = acc ->
        cond do
          n == 0 -> {:halt, conn}
          MapSet.member?(conn, pair) -> {:cont, acc}
          true -> {:cont, {MapSet.put(conn, pair), n - 1}}
        end
      end)

    pairs
    |> Enum.reduce([], fn {j1, j2}, circuits -> insert(circuits, j1, j2) end)
    |> merge_all(junctions)
    |> Enum.sort_by(&MapSet.size(&1), :desc)
    |> Enum.take(3)
    |> Enum.product_by(&MapSet.size(&1))
  end

  @impl true
  def part2(_junctions) do
  end

  defp parse(n) do
    {res, _} = Integer.parse(n)
    res
  end

  defp distance({x1, y1, z1}, {x2, y2, z2}) do
    diff_x = x1 - x2
    diff_y = y1 - y2
    diff_z = z1 - z2
    :math.sqrt(diff_x * diff_x + diff_y * diff_y + diff_z * diff_z)
  end

  defp insert(circuits, j1, j2) do
    res =
      Enum.reduce_while(circuits, {[], circuits}, fn circuit, {updated, [_ | remaining]} ->
        cond do
          MapSet.member?(circuit, j1) ->
            {:halt, {:updated, [MapSet.put(circuit, j2) | updated] ++ remaining}}

          MapSet.member?(circuit, j2) ->
            {:halt, {:updated, [MapSet.put(circuit, j1) | updated] ++ remaining}}

          true ->
            {:cont, {[circuit | updated], remaining}}
        end
      end)

    case res do
      {:updated, circuits} -> circuits
      _ -> [MapSet.new([j1, j2]) | circuits]
    end
  end

  defp merge_all(circuits, junctions) do
    Enum.reduce(junctions, circuits, fn j, circuits ->
      merge(circuits, j)
    end)
  end

  defp merge(circuits, j) do
    case merge_once(circuits, j) do
      {:noop, circuits} -> circuits
      {:merged, circuits} -> merge(circuits, j)
    end
  end

  defp merge_once(circuits, j) do
    case Enum.split_while(circuits, &(not MapSet.member?(&1, j))) do
      {_, []} ->
        {:noop, circuits}

      {pre, [first | mid]} ->
        case Enum.split_while(mid, &(not MapSet.member?(&1, j))) do
          {_, []} -> {:noop, circuits}
          {mid, [second | post]} -> {:merged, [MapSet.union(first, second) | pre ++ mid ++ post]}
        end
    end
  end
end

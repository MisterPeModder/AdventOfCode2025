defmodule AdventOfCodeRunner.Application do
  alias AdventOfCodeRunner.{Solution, SolutionInfo}
  use Application

  @impl true
  def start(_start_type, _start_args) do
    solution = AdventOfCode2025.Day01

    %SolutionInfo{year: year, day: day} = solution.info()

    IO.puts("== Running Advent of Code #{year} - Day #{day} ==")

    with {:ok, transformed} <- run_setup(solution, read_input()) do
      run_part(1, solution, transformed, &Solution.part1/2)
      run_part(2, solution, transformed, &Solution.part2/2)
    end

    {:ok, self()}
  end

  defp read_input() do
    IO.puts("Reading input from cache: ./input.txt")
    input = File.read!("input.txt")
    IO.puts("Read input: #{byte_size(input)} bytes")
    input
  end

  defp run_setup(solution, input) do
    IO.puts("Running setup function")

    case measure(fn -> Solution.setup(solution, input) end) do
      {:ok, transformed, elapsed} ->
        IO.puts("Setup function completed in #{elapsed}µs")
        {:ok, transformed}

      {:error, error, elapsed} ->
        IO.inspect(error, label: "Setup function failed in #{elapsed}µs")
        {:error, error}
    end
  end

  defp run_part(part, solution, transformed, run) do
    IO.puts("Running part #{part}")

    case measure(fn -> run.(solution, transformed) end) do
      {:ok, result, elapsed} ->
        IO.puts(
          "#{IO.ANSI.green()}Part #{part} completed in #{elapsed}µs => #{result}#{IO.ANSI.reset()}"
        )

        :ok

      {:error, error, elapsed} ->
        IO.inspect(error, label: "#{IO.ANSI.red()}Part #{part} failed in #{elapsed}µs")
        IO.write(IO.ANSI.reset())
        :error
    end
  end

  defp measure(func) do
    start_us = System.monotonic_time(:microsecond)
    {code, result} = func.()
    end_us = System.monotonic_time(:microsecond)
    elapsed = end_us - start_us
    {code, result, elapsed}
  end
end

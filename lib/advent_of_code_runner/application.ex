defmodule AdventOfCodeRunner.Application do
  alias AdventOfCodeRunner.Solution
  use Application

  @cache_dir ".aoc"
  @config_path "#{@cache_dir}/config.json"

  @help_text """
  Advent of Code solutions, powered by Elixir

  Usage: mix run -- -d <day>

  Supported options:
    --help, -h
    --year, -y
    --day, -d
  """

  @impl true
  def start(_start_type, _start_args) do
    {year, day} = parse_opts!()

    solution =
      :"Elixir.AdventOfCode#{year}.Day#{String.pad_leading(Integer.to_string(day), 2, "0")}"

    IO.puts("== Running Advent of Code #{year} - Day #{day} ==")

    File.mkdir_p!(@cache_dir)

    token =
      case read_token() do
        {:ok, t} -> t
        {:error, error} -> raise RuntimeError, "Failure to read token: #{error}"
      end

    input = fetch_input!(year, day, token)
    run_aoc(solution, input)

    {:ok, self()}
  end

  defp parse_opts!() do
    {opts, _} =
      OptionParser.parse!(System.argv(),
        strict: [year: :integer, day: :integer, help: :boolean],
        aliases: [y: :year, d: :day, h: :help]
      )

    if opts[:help] do
      IO.puts(@help_text)
      exit(0)
    end

    day =
      case opts[:day] do
        nil ->
          IO.puts(:stderr, @help_text)
          exit(1)

        d ->
          d
      end

    year = Keyword.get(opts, :year, 2025)

    {year, day}
  end

  defp run_aoc(solution, input) do
    with {:ok, transformed} <- run_setup(solution, input) do
      run_part(1, solution, transformed, &Solution.part1/2)
      run_part(2, solution, transformed, &Solution.part2/2)
    end
  end

  defp read_token() do
    case File.read(@config_path) do
      {:ok, data} ->
        case JSON.decode(data) do
          {:ok, %{"token" => token}} when is_binary(token) -> {:ok, token}
          {:ok, _} -> {:error, "Missing \"token\" string in configuration at #{@config_path}"}
          error -> error
        end

      {:error, :enoent} ->
        empty_config = JSON.encode_to_iodata!(%{token: ""})

        if File.write(@config_path, empty_config) === :ok do
          IO.puts("Created empty configuration at #{@config_path}")
        end

        {:error, :file.format_error(:enoent)}

      {:error, error} ->
        {:error, :file.format_error(error)}
    end
  end

  defp fetch_input!(year, day, token) do
    path = "#{@cache_dir}/input_#{year}_#{day}.txt"

    IO.puts("Reading input from cache: #{path}")

    input =
      case File.read(path) do
        {:ok, input} ->
          IO.puts("Read input from cache: #{byte_size(input)} bytes")
          input

        {:error, :enoent} ->
          download_input!(year, day, token)
      end

    File.write(path, input)
    input
  end

  defp download_input!(year, day, token) do
    url = "https://adventofcode.com/#{year}/day/#{day}/input"
    IO.puts("Downloading input from #{url}")

    res =
      Req.new(url: url)
      |> Req.Request.put_header("cookie", "session=#{token}")
      |> Req.request!()

    case res do
      %Req.Response{status: 200, body: input} ->
        IO.puts("Downloaded input from #{url}: #{byte_size(input)} bytes")
        input

      %Req.Response{status: status} = res ->
        raise "Received unexpected status #{status}: #{Map.get(res, :body, "(no body)")}"
    end
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

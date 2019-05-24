defmodule UmbrellaStreamlineFormatter do
  @moduledoc false
  use GenServer

  alias ExUnit.CLIFormatter, as: BaseFormatter

  import ExUnit.Formatter, only: [format_time: 2]

  ## Callbacks

  def init(opts) do
    {:ok, config} = BaseFormatter.init(opts)

    {:ok, Map.put(config, :condensed, Mix.Task.recursing?())}
  end

  def handle_cast({:suite_finished, run_us, load_us}, config) do
    print_suite(config, run_us, load_us)
    {:noreply, config}
  end

  def handle_cast(x, config) do
    BaseFormatter.handle_cast(x, config)
  end

  ## Tracing

  defp normalize_us(us) do
    div(us, 1000)
  end

  defp format_us(us) do
    us = div(us, 10)

    if us < 10 do
      "0.0#{us}"
    else
      us = div(us, 10)
      "#{div(us, 10)}.#{rem(us, 10)}"
    end
  end

  ## Slowest

  defp format_slowest_total(%{slowest: slowest} = config, run_us) do
    slowest_us =
      config
      |> extract_slowest_tests()
      |> Enum.reduce(0, &(&1.time + &2))

    slowest_time =
      slowest_us
      |> normalize_us()
      |> format_us()

    percentage = Float.round(slowest_us / run_us * 100, 1)

    "Top #{slowest} slowest (#{slowest_time}s), #{percentage}% of total time:\n"
  end

  defp format_slowest_times(config) do
    config
    |> extract_slowest_tests()
    |> Enum.map(&format_slow_test/1)
  end

  defp format_slow_test(%ExUnit.Test{name: name, time: time, module: module}) do
    "  * #{name} (#{format_us(time)}ms) (#{inspect(module)})\n"
  end

  defp extract_slowest_tests(%{slowest: slowest, test_timings: timings} = _config) do
    timings
    |> Enum.sort_by(fn %{time: time} -> -time end)
    |> Enum.take(slowest)
  end

  ## Printing

  defp print_suite(config, run_us, load_us) do
    print_list =
      []
      |> prepend("\n")
      |> prepend("\n")
      |> prepend(format_time(run_us, load_us))

    print_list =
      if config.slowest > 0 do
        print_list
        |> prepend("\n")
        |> prepend(format_slowest_total(config, run_us))
        |> prepend(format_slowest_times(config))
      else
        print_list
      end

    # singular/plural
    test_type_counts = format_test_type_counts(config)
    failure_pl = pluralize(config.failure_counter, "failure", "failures")

    message =
      "#{test_type_counts}#{config.failure_counter} #{failure_pl}"
      |> if_true(config.excluded_counter > 0, &(&1 <> ", #{config.excluded_counter} excluded"))
      |> if_true(config.invalid_counter > 0, &(&1 <> ", #{config.invalid_counter} invalid"))
      |> if_true(
        config.skipped_counter > 0,
        &(&1 <> ", " <> skipped("#{config.skipped_counter} skipped", config))
      )

    status_fn =
      cond do
        config.failure_counter > 0 -> &failure/2
        config.invalid_counter > 0 -> &invalid/2
        true -> &success/2
      end

    print_list =
      print_list
      |> prepend("\n")
      |> prepend(message)
      |> prepend("\n")
      |> prepend("Randomized with seed #{config.seed}")
      |> Enum.reverse()

    if config.condensed do
      IO.write("\n")

      print_list
      |> Enum.reject(&(&1 == "\n"))
      |> Enum.map(&status_fn.(&1, config))
      |> Enum.intersperse(" - ")
      |> Enum.each(&IO.write/1)
    else
      Enum.each(print_list, &IO.write(status_fn.(&1, config)))
    end

    IO.write("\n")
  end

  defp prepend(list, item), do: [item | list]

  defp if_true(value, false, _fun), do: value
  defp if_true(value, true, fun), do: fun.(value)

  defp format_test_type_counts(%{test_counter: test_counter} = _config) do
    Enum.map(test_counter, fn {test_type, count} ->
      type_pluralized = pluralize(count, test_type, ExUnit.plural_rule(test_type |> to_string()))
      "#{count} #{type_pluralized}, "
    end)
  end

  # Color styles

  defp colorize(escape, string, %{colors: colors}) do
    if colors[:enabled] do
      [escape, string, :reset]
      |> IO.ANSI.format_fragment(true)
      |> IO.iodata_to_binary()
    else
      string
    end
  end

  defp success(msg, config) do
    colorize(:green, msg, config)
  end

  defp invalid(msg, config) do
    colorize(:yellow, msg, config)
  end

  defp skipped(msg, config) do
    colorize(:yellow, msg, config)
  end

  defp failure(msg, config) do
    colorize(:red, msg, config)
  end

  defp pluralize(1, singular, _plural), do: singular
  defp pluralize(_, _singular, plural), do: plural
end

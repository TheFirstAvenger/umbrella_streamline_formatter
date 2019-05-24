# UmbrellaStreamlineFormatter

Streamlines umbrella test output from a minimum of 7 lines down to a minimum of 3 lines.

## Installation

Add `umbrella_streamline_formatter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:umbrella_streamline_formatter, "~> 0.1.0"}
  ]
end
```

And configure ExUnit in `test_helpers.exs` on your child apps. Note you technically only need to configure it on the first app that runs in your test suite:

```elixir
ExUnit.configure formatters: [UmbrellaStreamlineFormatter]
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/umbrella_streamline_formatter](https://hexdocs.pm/umbrella_streamline_formatter).


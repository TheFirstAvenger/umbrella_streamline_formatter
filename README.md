# UmbrellaStreamlineFormatter

Streamlines umbrella test output from a minimum of 7 lines down to a minimum of 3 lines.

Before:
![Screen Shot 2019-05-24 at 1 34 06 PM](https://user-images.githubusercontent.com/8557871/58346383-c3c88200-7e28-11e9-828a-0ef17c54fe71.png)

After:
![Screen Shot 2019-05-24 at 1 30 59 PM](https://user-images.githubusercontent.com/8557871/58346394-ca56f980-7e28-11e9-925e-38c15df7f495.png)

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


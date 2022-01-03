# Todo

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `todo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:todo, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/todo](https://hexdocs.pm/todo).

## Cutting a new OTP Release

Run the following command:

```
mix release
```

This will create a new OTP Release under the local folder `./_build/prod/rel/todo/`. This release contains an Erlang/Elixir runtime
and binaries of all dependencies. This prevents polluting target build machines with compile or runtime tools,
and lets us simply push binaries to the target machines, supply a couple start commands, and have a running web server.

### Starting an OTP Release

CD to the repository project directory and run the following command.
This command starts the release in the foreground to verify that the system is running:

```
_build/prod/rel/todo/bin/todo start_iex
```

Starting the process in the background is as simple as running the following command:

```
_build/prod/rel/todo/bin/todo start
```
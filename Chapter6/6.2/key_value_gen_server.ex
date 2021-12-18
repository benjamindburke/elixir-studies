# KeyValueStore
# Explore servers that utilize the GenServer wrapper of the OTP gen_server behaviour
defmodule KeyValueStore do
  use GenServer

  # ---------
  # GenServer behaviour hook functions
  # ---------

  # hook into GenServer
  # the @impl module attribute can perform compile-time checking of contracts between behaviours
  @impl GenServer
  def init(_) do
    # say there's a use case for periodic tasks such as server cleanup
    # the Erlang library :timer.send_interval/2 can be used to periodically send data to the server
    :timer.send_interval(5000, :cleanup)
    {:ok, %{}}

    # we can also choose not to start the server, or to ignore the request:

    # using the form {:stop, reason}, the return signature of start/0 will be {:error, reason}
    # {:stop, reason} should be used when the server has encountered an error and cannot proceed

    # using the form :ignore, the return signature of start/0 will be :ignore
    # :ignore should be used when stopping the server is a normal course of action
  end

  # the handle_info GenServer hook can be used to listen to periodically emitted data
  # these requests are neither calls nor casts
  # the @impl module attribute can perform compile-time checking of contracts between behaviours
  @impl GenServer
  def handle_info(:cleanup, state) do
    IO.puts("Performing cleanup...")
    {:noreply, state}
  end

  # requests to stop the server can also be issued inside handle_* functions

  # returning {:stop, reason, new_state} will cause GenServer to stop the running process
  # :normal should be used as the stoppage reason if stopping the process is standard workflow

  # the @impl module attribute can perform compile-time checking of contracts between behaviours
  @impl GenServer
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  # if a handle_call/3 function returns a stoppage and also needs to respond to the caller,
  # return {:stop, reason, rseponse, new_state}
  # but why return a new_state if the process is terminating?
  # in some cases, new_state may be necessary for any necessary cleanup

  # the @impl module attribute can perform compile-time checking of contracts between behaviours
  # handle_call functions must always be arity 3, never arity 2
  # as GenServer requires arity 3, this will raise a compilation error if not arity 3
  @impl GenServer
  def handle_call({:get, key}, _, state) do
    # _ is a tuple containing the request ID (created by GenServer internals) and the calling pid
    # this example has no use for this information so we ignore it
    {:reply, Map.get(state, key), state}
  end

  # ---------
  # Interface functions
  # ---------

  def start do
    # using the __MODULE__ special form,
    # we can freely change the KeyValueStore name in one place and have it update everywhere
    GenServer.start(
      __MODULE__, # current module name (KeyValueStore)
      nil, # initial state
      name: __MODULE__ # local name that applies only to the currently running BEAM instance (KeyValueStore)
    )
  end

  def stop(reason \\ :normal, timeout \\ :infinity) do
    # the server can also be stopped using GenServer.stop/3
    GenServer.stop(__MODULE__, reason, timeout)
  end

  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  def get(key) do
    # NOTE: GenServer.call/2 does not wait indefinitely for a response
    # After a default of 5 seconds, the request times out
    # GenServer.call/3 can be used to specify a longer timeout
    GenServer.call(__MODULE__, {:get, key})
  end
end
# ServerProcess
# A generic server implementation to illustrate how GenServer works
defmodule ServerProcess do
    def start(callback_module) do
        spawn(fn ->
            # callback_module must have an exported init/1 function
            initial_state = callback_module.init()
            loop(callback_module, initial_state)
        end)
    end

    defp loop(callback_module, current_state) do
        receive do
            {:call, request, caller} ->
                # send the request to be handled by the callback_module
                {response, new_state} = callback_module.handle_call(
                    request,
                    current_state
                )
                # sends the response back to the caller
                send(caller, {:response, response})
                # keep looping the server process with the new state
                loop(callback_module, new_state)
            {:cast, request} ->
                new_state = callback_module.handle_cast(
                    request,
                    current_state
                )
                # keep looping the server process with the new state
                loop(callback_module, new_state)
        end
    end

    # ---------
    # Synchronous generic functions
    # ---------

    def call(server_pid, request) do
        # send the server a request
        send(server_pid, {:call, request, self()})
        receive do
            # wait for response and return
            {:response, response} ->
                response
        end
    end

    # ---------
    # Asyncronous generic functions
    # ---------

    def cast(server_pid, request) do
        send(server_pid, {:cast, request})
    end

end

# KeyValueStore
# A generic module implementation to illustrate how GenServer operates module code as a server
defmodule KeyValueStore do
    # ---------
    # Synchronous generic abstracted functions, invoked in the server process
    # ---------

    def init, do: %{}

    def handle_call({:put, key, value}, state) do
        {:ok, Map.put(state, key, value)}
    end
    def handle_call({:get, key}, state) do
        {Map.get(state, key), state}
    end

    # ---------
    # Aynchronous generic abstracted functions, invoked in the server process
    # ---------

    def handle_cast({:put, key, value}, state) do
        Map.put(state, key, value)
    end

    # ---------
    # Interface functions (invoked by the client)
    # ---------

    def start do
        ServerProcess.start(KeyValueStore)
    end

    def put(pid, key, value) do
        ServerProcess.cast(pid, {:put, key, value})
    end

    def get(pid, key) do
        ServerProcess.call(pid, {:get, key})
    end
end
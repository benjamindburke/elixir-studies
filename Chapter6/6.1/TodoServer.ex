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

defmodule TodoList do
    @doc "auto_id will contain the ID value assigned to the new entry"
    defstruct auto_id: 1, entries: %{}
end

defmodule TodoServer do
    # ---------
    # Synchronous generic abstracted functions, invoked in the server process
    # ---------

    def init, do: %TodoList{}

    def handle_call({:add_entry, new_entry}, todo_list) do
        entry = Map.put(entry, :id, todo_list.auto_id)
        new_entries = Map.put(
            todo_list.entries,
            todo_list.auto_id,
            entry
        )
        %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
    end
    def handle_call({:delete_entry, id}, todo_list) do
        Map.delete(todo_list.entries, id)
    end
    def handle_call({:update_entry, entry_id, updater_fun}, todo_list) do
        # TODO : when updating an entry, why is the entire entry overwritten and the two don't merge?
        case Map.fetch(todo_list.entries, entry_id) do
            :error -> todo_list
            {:ok, old_entry} ->
                old_entry_id = old_entry.id
                new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
                new_entries = Map.put(todo_list.entries, new_entry.id, Map.merge(new_entry, todo_list.entries[new_entry.id], fn _k, v1, _v2 -> v1 end))
                %TodoList{todo_list | entries: new_entries}
        end
    end

    # ---------
    # Aynchronous generic abstracted functions, invoked in the server process
    # ---------

    def handle_cast({:entries, caller, id}, todo_list) when is_integer(id) do
        send(caller, {:todo_entries, Map.get(todo_list.entries, id)})
        todo_list
    end
    def handle_cast({:entries, caller, %Date{} = date}, todo_list) do
        send(caller, {:todo_entries,
            todo_list.entries()
            |> Stream.filter(fn {_, entry} -> entry.date == date end) # Filters entries for a given date
            |> Enum.map(fn {_, entry} -> entry end) # Takes only values
        })
        todo_list
    end
    def handle_cast({:entries, caller, title}, todo_list) when is_binary(title) do
        send(caller,
            {:todo_entries,
            todo_list.entries()
            |> Stream.filter(fn {_, entry} -> entry.title == title end) # Filters entries for a given date
            |> Enum.map(fn {_, entry} -> entry end) # Takes only values
        })
        todo_list
    end

    # ---------
    # Interface functions (invoked by the client)
    # ---------

    def start do
        ServerProcess.start(TodoServer)
    end

    def add_entry(todo_server, new_entry) do
        ServerProcess.call(todo_server, {:add_entry, new_entry})
    end

    def entries(todo_server, query) do
        ServerProcess.cast(todo_server, {:entries, self(), query})
        receive do
            {:todo_entries, entries} -> entries
        after
            5000 -> {:error, :timeout}
        end
    end

    def delete_entry(todo_server, id) do
        ServerProcess.call(todo_server, {:delete_entry, id})
    end

    def update_entry(todo_server, %{} = new_entry) do
        ServerProcess.call(
            todo_server,
            {:update_entry, new_entry.id, fn _ -> new_entry end}
        )
    end
end



# entries = [
#     %{date: ~D[2018-12-19], title: "Dentist"},
#     %{date: ~D[2018-12-20], title: "Shopping"},
#     %{date: ~D[2018-12-19], title: "Movies"}
# ]
# server = TodoServer.start()
# Enum.each(entries, &TodoServer.add_entry(server, &1))
# TodoServer.entries(server, ~D[2018-12-19])
# TodoServer.entries(server, 1)
# TodoServer.update_entry(server, %{id: 2, title: "Feeding Pesto"})
# TodoServer.add_entry(server, %{date: ~D[2021-11-08], title: "Feeding Pesto"})
# TodoServer.entries(server, "Feeding Pesto")
# TodoServer.delete_entry(server, 4)

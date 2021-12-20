defmodule Todo.Cache do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache, todo_list_name) do
    GenServer.call(cache, {:server_process, todo_list_name})
  end

  @impl GenServer
  def init(_) do
    Todo.Database.start()
    {:ok, %{}}
  end

  # this request must be sent directly to the caller, so it must be a handle_call function
  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}
      :error ->
        {:ok, new_server} = Todo.Server.start(todo_list_name)

        {
          :reply,
          new_server,
          Map.put(todo_servers, todo_list_name, new_server)
        }
    end
  end
end

# TEST CODE
# ---------

# {:ok, cache} = Todo.Cache.start()
# Todo.Cache.server_process("Bob's list")
# Todo.Cache.server_process("Bob's list")
# Todo.Cache.server_process("Alice's list")
# bobs_list = Todo.Cache.server_process("Bob's list")
# Enum.each(
#   1..100_000,
#   fn index ->
#     Todo.Cache.server_process("to-do list #{index}")
#   end
# )
# :erlang.system_info(:process_count)
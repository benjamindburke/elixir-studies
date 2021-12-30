defmodule TodoCacheTest do
  use EsUnit.Case

  test "server_process" do
    bob_pid = Todo.Cache.server_process("bob") # cache is started automatically thanks to Application callback
    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end
end

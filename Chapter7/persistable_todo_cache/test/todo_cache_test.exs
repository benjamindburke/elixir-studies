# test files are only tested if the filename ends in _test.exs

defmodule TodoCacheTest do
  use ExUnit.Case

  test "server process" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "bob")

    # assert the bob process and the alice process are not the same
    assert bob_pid != Todo.Cache.server_process(cache, "alice")
    # assert the bob process is the same process after another invocation
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
  end

  test "to-do operations" do
    {:ok, cache} = Todo.Cache.start()
    alice = Todo.Cache.server_process(cache, "alice")
    Todo.Server.add_entry(alice, %{date: ~D[2018-12-19], title: "Dentist"})
    entries = Todo.Server.entries(alice, ~D[2018-12-19])

    # assert can also be used to test that an expression matches the pattern
    assert [%{date: ~D[2018-12-19], title: "Dentist"}] = entries
  end
end
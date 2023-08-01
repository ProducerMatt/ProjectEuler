defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do     #1
    Todo.System.start_link()
    bob_pid = Todo.Cache.server_process("bob")
    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")     #2
  end
  test "to-do operations" do
    Todo.System.start_link()
    alice = Todo.Cache.server_process("alice")
    Todo.Server.add_entry(alice, %{date: ~D[2023-12-19], title: "Dentist"})
    entries = Todo.Server.entries(alice, ~D[2023-12-19])
    assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries    #1
    Todo.Server.reset_db(alice)
  end
end

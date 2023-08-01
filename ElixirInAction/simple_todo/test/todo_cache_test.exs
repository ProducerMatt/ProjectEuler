defmodule Todo.CacheTest do
  use ExUnit.Case
  doctest Todo.Cache

  describe "Todo.Cache" do
    test "server_process" do
      Todo.System.start_link()
      bob_pid = Todo.Cache.server_process("test_server_process")
      assert bob_pid != Todo.Cache.server_process("test_nonexistent")
      assert bob_pid == Todo.Cache.server_process("test_server_process")
    end
    test "to-do operations" do
      Todo.System.start_link()
      alice = Todo.Cache.server_process("test_todo_ops")
      Todo.Server.add_entry(alice, %{date: ~D[2023-12-19], title: "Dentist"})
      entries = Todo.Server.entries(alice, ~D[2023-12-19])
      assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries
      Todo.Server.reset_db(alice)
    end
  end
end

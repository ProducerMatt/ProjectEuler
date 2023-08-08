defmodule Todo.CacheTest do
  use ExUnit.Case
  doctest Todo.Cache

  describe "Todo.Cache" do
    test "server_process" do
      {:ok, sys_pid} = Todo.System.start_link()
      bob_pid = Todo.Cache.server_process("test_server_process")
      assert bob_pid != Todo.Cache.server_process("test_nonexistent")
      assert bob_pid == Todo.Cache.server_process("test_server_process")
      Todo.System.stop(sys_pid)
    end
    test "to-do operations" do
      {:ok, sys_pid} = Todo.System.start_link()
      alice = Todo.Cache.server_process("test_todo_ops")
      Todo.Server.add_entry(alice, %{date: ~D[2023-12-19], title: "Dentist"})
      entries = Todo.Server.entries(alice, ~D[2023-12-19])
      assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries
      Todo.Server.reset_db(alice)
      Todo.System.stop(sys_pid)
    end
    test "crashable cache workers" do
      {:ok, sys_pid} = Todo.System.start_link()
      bobs_list = Todo.Cache.server_process("Bob's list")
      bobs_list_backup = Todo.Cache.server_process("Bob's list")
      assert(bobs_list == bobs_list_backup)
      alices_list = Todo.Cache.server_process("Alice's list")
      assert(bobs_list != alices_list)
      Process.exit(bobs_list, :kill) # crash
      bobs_list = Todo.Cache.server_process("Bob's list")
      assert(bobs_list != bobs_list_backup)
      assert(alices_list == Todo.Cache.server_process("Alice's list"))
      Todo.System.stop(sys_pid)
    end
  end
end

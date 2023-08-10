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
    test "crashable list server workers" do
      {:ok, sys_pid} = Todo.System.start_link()
      bobs_list = Todo.Cache.server_process("crashing list")
      bobs_list_backup = Todo.Cache.server_process("crashing list")
      assert(bobs_list == bobs_list_backup)
      alices_list = Todo.Cache.server_process("unrelated list")
      assert(bobs_list != alices_list)
      Process.exit(bobs_list, :kill) # crash
      bobs_list = Todo.Cache.server_process("crashing list")
      assert(bobs_list != bobs_list_backup)
      assert(alices_list == Todo.Cache.server_process("unrelated list"))
      Todo.System.stop(sys_pid)
    end
    test "crashable database workers" do
      {:ok, sys_pid} = Todo.System.start_link()
      bobs_list = Todo.Cache.server_process("Bobs server")
      bobs_list_backup = Todo.Cache.server_process("Bobs server")
      assert(bobs_list == bobs_list_backup)
      alices_list = Todo.Cache.server_process("Alices server")
      assert(bobs_list != alices_list)
      bobs_list_db_worker = Todo.Database.worker_pid("Bobs server")
      alices_list_db_worker = Todo.Database.worker_pid("Alices server")
      IO.puts("crashing Bob's database worker")
      Process.exit(bobs_list_db_worker, :kill) # crash
      #Process.sleep(100)
      assert(bobs_list_db_worker != Todo.Database.worker_pid("Bobs server"))
      assert(alices_list_db_worker == Todo.Database.worker_pid("Alices server"))
      assert(bobs_list == Todo.Cache.server_process("Bobs server"))
      assert(alices_list == Todo.Cache.server_process("Alices server"))
      Todo.System.stop(sys_pid)
    end
  end
end

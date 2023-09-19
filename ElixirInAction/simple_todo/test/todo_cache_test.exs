defmodule Todo.CacheTest do
  use ExUnit.Case, async: true
  doctest Todo.Cache

  describe "Todo.Cache" do
    test "server_process" do
      bob_pid = Todo.Cache.server_process("test_server_process")
      assert bob_pid != Todo.Cache.server_process("test_nonexistent")
      assert bob_pid == Todo.Cache.server_process("test_server_process")
    end
    test "to-do operations" do
      alice = Todo.Cache.server_process("test_todo_ops")
      Todo.Server.add_entry(alice, %{date: ~D[2023-12-19], title: "Dentist"})
      entries = Todo.Server.entries(alice, ~D[2023-12-19])
      assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries
      Todo.Server.reset_db(alice)
    end
    test "crashable list server workers" do
      bobs_list = Todo.Cache.server_process("crashing list")
      bobs_list_backup = Todo.Cache.server_process("crashing list")
      assert(bobs_list == bobs_list_backup)
      alices_list = Todo.Cache.server_process("unrelated list")
      assert(bobs_list != alices_list)
      Process.exit(bobs_list, :kill) # crash
      bobs_list = Todo.Cache.server_process("crashing list")
      assert(bobs_list != bobs_list_backup)
      assert(alices_list == Todo.Cache.server_process("unrelated list"))
    end
    ### TODO: bring this back one day
    #test "crashable database workers" do
    #  bobs_list = Todo.Cache.server_process("Bobs server")
    #  bobs_list_backup = Todo.Cache.server_process("Bobs server")
    #  assert(bobs_list == bobs_list_backup)
    #  alices_list = Todo.Cache.server_process("Alices server")
    #  assert(bobs_list != alices_list)
    #  bobs_list_db_worker = Todo.Database.worker_pid("Bobs server")
    #  alices_list_db_worker = Todo.Database.worker_pid("Alices server")
    #  IO.puts("crashing Bob's database worker")
    #  Process.exit(bobs_list_db_worker, :kill) # crash
    #  #Process.sleep(100)
    #  assert(bobs_list_db_worker != Todo.Database.worker_pid("Bobs server"))
    #  assert(alices_list_db_worker == Todo.Database.worker_pid("Alices server"))
    #  assert(bobs_list == Todo.Cache.server_process("Bobs server"))
    #  assert(alices_list == Todo.Cache.server_process("Alices server"))
    #end
  end

  # HACK: This deletes all files in the db_folder, assuming it's given a unique
  # test folder. Safer would be a list made during the testing process which
  # then gets removed
  ExUnit.after_suite(fn _ ->
    dir = Application.fetch_env!(:todo, :db_folder)
    dir
    |> File.ls!()
    |> Enum.map(fn i -> dir <> "/" <> i end)
    |> Enum.each(fn i -> IO.write("Removing #{i}\n"); File.rm!(i) end)
  end)
end

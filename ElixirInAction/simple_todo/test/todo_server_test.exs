defmodule TodoServerTest do
  use ExUnit.Case
  doctest Todo.Server

  @example_list %Todo.List{
    next_id: 4,
    entries: %{
      1 => %{date: ~D[2023-12-19], id: 1, title: "Dentist"},
      2 => %{date: ~D[2023-12-20], id: 2, title: "Shopping"},
      3 => %{date: ~D[2023-12-19], id: 3, title: "Movies"}
    }
  }
  @new_entry %{date: ~D[2023-12-21], title: "Flossing"}
  @new_entry_added %{date: ~D[2023-12-21], id: 4, title: "Flossing"}

  test "Todo.Server add" do
    Todo.Cache.start()
    entries = Map.values(@example_list.entries)
    {:ok, pid} = Todo.Server.start("test_add")
    Todo.Server.add_entries(pid, entries)
    Todo.Server.add_entry(pid, @new_entry)
    assert Todo.Server.entries(pid, @new_entry.date) == [@new_entry_added]
    Todo.Server.stop(pid)
  end
  test "Todo.Server.entries" do
    Todo.Cache.start()
    entries = Map.values(@example_list.entries)
    {:ok, pid} = Todo.Server.start("test_entries")
    Todo.Server.add_entries(pid, entries)
    expected = [
      @example_list.entries[1],
      @example_list.entries[3],
    ]
    assert expected == Todo.Server.entries(pid, ~D[2023-12-19])
    Todo.Server.stop(pid)
  end
  test "Todo.Server.update_entry" do
    Todo.Cache.start()
    entries = Map.values(@example_list.entries)
    {:ok, pid} = Todo.Server.start("test_update_entries")
    Todo.Server.add_entries(pid, entries)
    id = 1
    to_update = %{title: "Flossing"}
    Todo.Server.update_entry(pid, id, to_update)
    new_list = Todo.Server.entries(pid, ~D[2023-12-19])
    added_entry = Map.merge(@example_list.entries[id], to_update)
    assert List.first(new_list) == added_entry
    Todo.Server.stop(pid)
  end
  test "Todo.Server.delete_entry" do
    Todo.Cache.start()
    entries = Map.values(@example_list.entries)
    {:ok, pid} = Todo.Server.start("test_delete")
    Todo.Server.add_entries(pid, entries)
    Todo.Server.delete_entry(pid, 3)
    assert Todo.Server.entries(pid, @example_list.entries[1].date) == [@example_list.entries[1]]
    Todo.Server.stop(pid)
  end
end

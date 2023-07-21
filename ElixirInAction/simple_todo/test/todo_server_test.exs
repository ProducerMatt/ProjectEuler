defmodule TodoServerTest do
  use ExUnit.Case
  doctest TodoServer

  @knownGoodList %TodoList{
    next_id: 4,
    entries: %{
      1 => %{date: ~D[2023-12-19], id: 1, title: "Dentist"},
      2 => %{date: ~D[2023-12-20], id: 2, title: "Shopping"},
      3 => %{date: ~D[2023-12-19], id: 3, title: "Movies"}
    }
  }
  @newEntry %{date: ~D[2023-12-21], title: "Flossing"}
  @newEntryAdded %{date: ~D[2023-12-21], id: 4, title: "Flossing"}

  test "TodoServer add" do
    entries = Map.values(@knownGoodList.entries)
    pid = TodoServer.start(entries)
    TodoServer.add_entry(pid, @newEntry)
    assert TodoServer.entries(pid, @newEntry.date) == [@newEntryAdded]
  end
  test "TodoServer.entries" do
    entries = Map.values(@knownGoodList.entries)
    pid = TodoServer.start(entries)
    expected = [
      @knownGoodList.entries[1],
      @knownGoodList.entries[3],
    ]
    assert expected == TodoServer.entries(pid, ~D[2023-12-19])
  end
  test "TodoList.update_entry" do
    entries = Map.values(@knownGoodList.entries)
    pid = TodoServer.start(entries)
    id = 1
    to_update = %{title: "Flossing"}
    TodoServer.update_entry(pid, id, to_update)
    new_list = TodoServer.entries(pid, ~D[2023-12-19])
    added_entry = Map.merge(@knownGoodList.entries[id], to_update)
    assert List.first(new_list) == added_entry
  end
  test "TodoList.delete_entry" do
    entries = Map.values(@knownGoodList.entries)
    pid = TodoServer.start(entries)
    TodoServer.delete_entry(pid, 3)
    assert TodoServer.entries(pid, @knownGoodList.entries[1].date) == [@knownGoodList.entries[1]]
  end
end

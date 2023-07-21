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
    TodoServer.start(entries)
    TodoServer.add_entry(@newEntry)
    assert TodoServer.entries(@newEntry.date) == [@newEntryAdded]
    TodoServer.stop()
  end
  test "TodoServer.entries" do
    entries = Map.values(@knownGoodList.entries)
    TodoServer.start(entries)
    expected = [
      @knownGoodList.entries[1],
      @knownGoodList.entries[3],
    ]
    assert expected == TodoServer.entries(~D[2023-12-19])
    TodoServer.stop()
  end
  test "TodoList.update_entry" do
    entries = Map.values(@knownGoodList.entries)
    TodoServer.start(entries)
    id = 1
    to_update = %{title: "Flossing"}
    TodoServer.update_entry(id, to_update)
    new_list = TodoServer.entries(~D[2023-12-19])
    added_entry = Map.merge(@knownGoodList.entries[id], to_update)
    assert List.first(new_list) == added_entry
    TodoServer.stop()
  end
  test "TodoList.delete_entry" do
    entries = Map.values(@knownGoodList.entries)
    TodoServer.start(entries)
    TodoServer.delete_entry(3)
    assert TodoServer.entries(@knownGoodList.entries[1].date) == [@knownGoodList.entries[1]]
    TodoServer.stop()
  end
end

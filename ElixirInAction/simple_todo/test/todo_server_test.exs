defmodule TodoServerTest do
  use ExUnit.Case
  doctest Todo.Server

  @knownGoodList %Todo.List{
    next_id: 4,
    entries: %{
      1 => %{date: ~D[2023-12-19], id: 1, title: "Dentist"},
      2 => %{date: ~D[2023-12-20], id: 2, title: "Shopping"},
      3 => %{date: ~D[2023-12-19], id: 3, title: "Movies"}
    }
  }
  @newEntry %{date: ~D[2023-12-21], title: "Flossing"}
  @newEntryAdded %{date: ~D[2023-12-21], id: 4, title: "Flossing"}

  test "Todo.Server add" do
    entries = Map.values(@knownGoodList.entries)
    Todo.Server.start(entries)
    Todo.Server.add_entry(@newEntry)
    assert Todo.Server.entries(@newEntry.date) == [@newEntryAdded]
    Todo.Server.stop()
  end
  test "Todo.Server.entries" do
    entries = Map.values(@knownGoodList.entries)
    Todo.Server.start(entries)
    expected = [
      @knownGoodList.entries[1],
      @knownGoodList.entries[3],
    ]
    assert expected == Todo.Server.entries(~D[2023-12-19])
    Todo.Server.stop()
  end
  test "Todo.Server.update_entry" do
    entries = Map.values(@knownGoodList.entries)
    Todo.Server.start(entries)
    id = 1
    to_update = %{title: "Flossing"}
    Todo.Server.update_entry(id, to_update)
    new_list = Todo.Server.entries(~D[2023-12-19])
    added_entry = Map.merge(@knownGoodList.entries[id], to_update)
    assert List.first(new_list) == added_entry
    Todo.Server.stop()
  end
  test "Todo.Server.delete_entry" do
    entries = Map.values(@knownGoodList.entries)
    Todo.Server.start(entries)
    Todo.Server.delete_entry(3)
    assert Todo.Server.entries(@knownGoodList.entries[1].date) == [@knownGoodList.entries[1]]
    Todo.Server.stop()
  end
end

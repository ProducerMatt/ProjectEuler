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
    entries = Map.values(@example_list.entries)
    Todo.Server.start()
    Todo.Server.add_entries(entries)
    Todo.Server.add_entry(@new_entry)
    assert Todo.Server.entries(@new_entry.date) == [@new_entry_added]
    Todo.Server.stop()
  end
  test "Todo.Server.entries" do
    entries = Map.values(@example_list.entries)
    Todo.Server.start()
    Todo.Server.add_entries(entries)
    expected = [
      @example_list.entries[1],
      @example_list.entries[3],
    ]
    assert expected == Todo.Server.entries(~D[2023-12-19])
    Todo.Server.stop()
  end
  test "Todo.Server.update_entry" do
    entries = Map.values(@example_list.entries)
    Todo.Server.start()
    Todo.Server.add_entries(entries)
    id = 1
    to_update = %{title: "Flossing"}
    Todo.Server.update_entry(id, to_update)
    new_list = Todo.Server.entries(~D[2023-12-19])
    added_entry = Map.merge(@example_list.entries[id], to_update)
    assert List.first(new_list) == added_entry
    Todo.Server.stop()
  end
  test "Todo.Server.delete_entry" do
    entries = Map.values(@example_list.entries)
    Todo.Server.start()
    Todo.Server.add_entries(entries)
    Todo.Server.delete_entry(3)
    assert Todo.Server.entries(@example_list.entries[1].date) == [@example_list.entries[1]]
    Todo.Server.stop()
  end
end

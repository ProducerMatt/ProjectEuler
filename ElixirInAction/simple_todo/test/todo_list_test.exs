defmodule SimpleTodoTest do
  use ExUnit.Case
  doctest TodoList

  @knownGoodList %TodoList{
    next_id: 4,
    entries: %{
      1 => %{date: ~D[2023-12-19], id: 1, title: "Dentist"},
      2 => %{date: ~D[2023-12-20], id: 2, title: "Shopping"},
      3 => %{date: ~D[2023-12-19], id: 3, title: "Movies"}
    }
  }
  test "TodoList.CsvImporter" do
    assert TodoList.CsvImporter.import("./test/good.csv") == @knownGoodList
  end
  test "TodoList.new" do
    assert TodoList.new() == %TodoList{}
  end
  test "TodoList.new with entries" do
    entries = Map.values(@knownGoodList.entries)
    assert TodoList.new(entries) == @knownGoodList
  end
  test "TodoList.add_entry" do
    entry = %{date: ~D[2023-12-21], title: "Flossing"}
    new_list = TodoList.add_entry(@knownGoodList, entry)
    added_entry = Map.put_new(entry, :id, 4)
    assert new_list.entries[4] == added_entry
    assert new_list.next_id == 5
  end
  test "TodoList.entries" do
    expected = [
      @knownGoodList.entries[1],
      @knownGoodList.entries[3],
    ]
    assert expected == TodoList.entries(@knownGoodList, ~D[2023-12-19])
  end
  test "TodoList.update_entry" do
    id = 1
    to_update = %{title: "Flossing"}
    new_list = TodoList.update_entry(@knownGoodList, id, to_update)
    added_entry = Map.merge(@knownGoodList.entries[id], to_update)
    assert new_list.entries[1] == added_entry
    assert new_list.next_id == 4
  end
  test "TodoList.delete_entry" do
    new_list = TodoList.delete_entry(@knownGoodList, 1)
    expected = [
      @knownGoodList.entries[3]
    ]
    assert expected == TodoList.entries(new_list, ~D[2023-12-19])
  end
end

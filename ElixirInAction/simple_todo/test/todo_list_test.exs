defmodule SimpleTodoTest do
  use ExUnit.Case
  doctest Todo.List

  @doc """
    An example todo list that should include all fields
  """
  @example_list %Todo.List{
    next_id: 4,
    entries: %{
      1 => %{date: ~D[2023-12-19], id: 1, title: "Dentist"},
      2 => %{date: ~D[2023-12-20], id: 2, title: "Shopping"},
      3 => %{date: ~D[2023-12-19], id: 3, title: "Movies"}
    }
  }
  describe "Todo.List" do
    test "Todo.List.CsvImporter" do
      assert Todo.List.CsvImporter.import("./test/good.csv") == @example_list
    end
    test "Todo.List.new" do
      assert Todo.List.new() == %Todo.List{}
    end
    test "Todo.List.new with entries" do
      entries = Map.values(@example_list.entries)
      assert Todo.List.new(entries) == @example_list
    end
    test "Todo.List.add_entry" do
      entry = %{date: ~D[2023-12-21], title: "Flossing"}
      new_list = Todo.List.add_entry(@example_list, entry)
      added_entry = Map.put_new(entry, :id, 4)
      assert new_list.entries[4] == added_entry
      assert new_list.next_id == 5
    end
    test "Todo.List.entries" do
      expected = [
        @example_list.entries[1],
        @example_list.entries[3],
      ]
      assert expected == Todo.List.entries(@example_list, ~D[2023-12-19])
    end
    test "Todo.List.update_entry" do
      id = 1
      to_update = %{title: "Flossing"}
      new_list = Todo.List.update_entry(@example_list, id, to_update)
      added_entry = Map.merge(@example_list.entries[id], to_update)
      assert new_list.entries[1] == added_entry
      assert new_list.next_id == 4
    end
    test "Todo.List.delete_entry" do
      new_list = Todo.List.delete_entry(@example_list, 1)
      expected = [
        @example_list.entries[3]
      ]
      assert expected == Todo.List.entries(new_list, ~D[2023-12-19])
    end
  end
end

defmodule Todo.List do
  defstruct [next_id: 1, entries: %{}]
  @type t :: %__MODULE__{next_id: integer, entries: map}
  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %Todo.List{},
      &add_entry(&2, &1)
    )
  end
  @spec add_entry(Todo.List.t, map) :: Todo.List.t
  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)
    new_entries = Map.put(
      todo_list.entries,
      todo_list.next_id,
      entry
    )
    %Todo.List{todo_list |
              entries: new_entries,
              next_id: todo_list.next_id + 1
    }
  end
  @spec update_entry(Todo.List.t, integer, map) :: Todo.List.t
  def update_entry(todo_list, id, entry) do
    updated = Map.merge(todo_list.entries[id], entry)
    new_entries = Map.put(todo_list.entries, id, updated)
    Map.put(todo_list, :entries, new_entries)
  end
  @spec entries(Todo.List.t, Date) :: list
  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end
  def delete_entry(todo_list, id) do
    new_entries = Map.delete(todo_list.entries, id)
    Map.put(todo_list, :entries, new_entries)
  end
end

defmodule Todo.List.CsvImporter do

  defp file_stream(path) do
    File.stream!(path)
    |> Stream.map(&String.trim_trailing(&1, "\n"))
  end

  def import(path) do
    file_stream(path)
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn l ->
      [ dateString, title ] = l
      case Date.from_iso8601(dateString) do
        {:ok, date} -> %{date: date, title: title}
        other -> throw("bad css]v: #{dateString} -> #{other}")
      end
    end)
    |> Todo.List.new()
  end
end

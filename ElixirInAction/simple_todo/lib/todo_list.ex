defmodule TodoList do
  @moduledoc """
  Documentation for `SimpleTodo`.
  """

  @doc """
  Hello world.

  ## Examples

  iex> SimpleTodo.hello()
  :world

  """
  defstruct next_id: 1, entries: %{}
  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end
  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)
    new_entries = Map.put(
      todo_list.entries,
      todo_list.next_id,
      entry
    )
    %TodoList{todo_list |
              entries: new_entries,
              next_id: todo_list.next_id + 1
    }
  end
  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end
end

defmodule TodoList.CsvImporter do

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
    |> TodoList.new()
  end
end

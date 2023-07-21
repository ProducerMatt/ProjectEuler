defmodule TodoServer do

  @spec start(atom() | list()) :: pid
  def start(entries \\ nil) do
    pid = spawn(fn ->
      cond do
	      Kernel.is_list(entries) ->
          loop(TodoList.new(entries))
        is_nil(entries) ->
          loop(TodoList.new())
      end
    end)
    Process.register(pid, :todo_server)
    pid
  end
  def stop do
    Process.exit(Process.whereis(:todo_server), :kill)
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
      message -> process_message(todo_list, message)
    end
    loop(new_todo_list)
  end

  def add_entry(new_entry) do
    send(:todo_server, {:add_entry, new_entry})
  end
  def update_entry(id, entry) do
    send(:todo_server, {:update_entry, id, entry})
  end
  def delete_entry(id) do
    send(:todo_server, {:delete_entry, id})
  end
  def entries(date) do
    send(:todo_server, {:entries, self(), date})
    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end
  defp process_message(todo_list, {:delete_entry, id}) do
    TodoList.delete_entry(todo_list, id)
  end
  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end
  defp process_message(todo_list, {:update_entry, id, entry}) do
    TodoList.update_entry(todo_list, id, entry)
  end
  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end
end

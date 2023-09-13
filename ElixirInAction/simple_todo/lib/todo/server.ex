defmodule Todo.Server do
  @moduledoc """
  Todo List: state-maintaining server functions
  """
  use Agent, restart: :temporary

  def start_link(name) do
    Agent.start_link(
      fn ->
        IO.puts("Starting to-do server for #{name}")
        {name, Todo.Database.get(name) || Todo.List.new()}
      end,
      name: via_tuple(name)
    )
  end

  def add_entry(todo_server, new_entry) do
    Agent.cast(todo_server, fn {name, todo_list} ->
      new_list = Todo.List.add_entry(todo_list, new_entry)
      Todo.Database.store(name, new_list)
      {name, new_list}
    end)
  end

  def entries(todo_server, date) do
    Agent.get(
      todo_server,
      fn {_name, todo_list} -> Todo.List.entries(todo_list, date) end
    )
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  def stop(pid) do
    Agent.stop(pid, :normal)
  end

  def add_entries(todo_server, new_entries) do
    Agent.cast(todo_server, fn {name, todo_list} ->
      new_list = Todo.List.add_entries(todo_list, new_entries)
      Todo.Database.store(name, new_list)
      {name, new_list}
    end)
  end

  def update_entry(todo_server, id, entry) do
    Agent.cast(todo_server, fn {name, todo_list} ->
      new_list = Todo.List.update_entry(todo_list, id, entry)
      Todo.Database.store(name, new_list)
      {name, new_list}
    end)
  end

  def delete_entry(todo_server, id) do
    Agent.cast(todo_server, fn {name, todo_list} ->
      new_list = Todo.List.delete_entry(todo_list, id)
      Todo.Database.store(name, new_list)
      {name, new_list}
    end)
  end

  def reset_db(todo_server) do
    Agent.cast(todo_server, fn {name, _todo_list} ->
      new_list = Todo.List.new()
      Todo.Database.store(name, new_list)
      {name, new_list}
    end)
  end
end

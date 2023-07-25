defmodule Todo.Server do
  @moduledoc """
  Todo List: state-maintaining server functions
  """
  use GenServer

  @spec start(Todo.Cache.cache_key) :: {:ok, pid}
  def start(name) do
    result = GenServer.start(__MODULE__, name)
    case result do
      {:ok, pid} -> {:ok, pid}
      x -> throw("Unexpected: #{x}")
    end
  end
  @impl GenServer
  @spec init(Todo.Cache.cache_key) :: {:ok, {Todo.Cache.cache_key, nil}, {:continue, :init}}
  def init(name) do
    {:ok, {name, nil}, {:continue, :init}}
  end
  @impl GenServer
  @spec handle_continue(:init, {Todo.Cache.cache_key, nil}) :: {:noreply, {Todo.Cache.cache_key, Todo.List.t}}
  def handle_continue(:init, {name, nil}) do
    todo_list = Todo.Database.get(name) || Todo.List.new()
    {:noreply, {name, todo_list}}
  end
  def stop(pid) do
    GenServer.stop(pid, :normal)
  end

  @impl GenServer
  def handle_call(request, _from, {name, todo_list}) do
    case request do
      {:entries, date} ->
        {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
    end
  end
  @impl GenServer
  def handle_cast(request, {name, todo_list}) do
    case request do
      {:add_entry, new_entry} ->
        new_list = Todo.List.add_entry(todo_list, new_entry)
        Todo.Database.store(name, new_list)
        {:noreply, {name, new_list}}
      {:add_entries, new_entries} ->
        new_list = Todo.List.add_entries(todo_list, new_entries)
        Todo.Database.store(name, new_list)
        {:noreply, {name, new_list}}
      {:update_entry, id, entry} ->
        new_list = Todo.List.update_entry(todo_list, id, entry)
        Todo.Database.store(name, new_list)
        {:noreply, {name, new_list}}
      {:delete_entry, id} ->
        new_list = Todo.List.delete_entry(todo_list, id)
        Todo.Database.store(name, new_list)
        {:noreply, {name, new_list}}
    end
  end
  def add_entry(pid, new_entry) do
    GenServer.cast(__MODULE__, {:add_entry, pid, new_entry})
  end
  def add_entries(pid, new_entries) do
    GenServer.cast(__MODULE__, {:add_entries, pid, new_entries})
  end
  def update_entry(pid, id, entry) do
    GenServer.cast(__MODULE__, {:update_entry, pid, id, entry})
  end
  def delete_entry(pid, id) do
    GenServer.cast(__MODULE__, {:delete_entry, pid, id})
  end
  def entries(pid, date) do
    GenServer.call(__MODULE__, {:entries, pid, date})
  end
end

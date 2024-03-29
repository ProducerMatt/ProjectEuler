defmodule Todo.Server do
  @moduledoc """
  Todo List: state-maintaining server functions
  """
  use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.seconds(10)

  @spec start_link(Todo.Cache.cache_key) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(name) do
    IO.puts("Starting server #{name}")
    GenServer.start_link(__MODULE__, name, name: global_name(name))
  end

  defp global_name(name) do
    {:global, {__MODULE__, name}}
  end

  def whereis(name) do
    case :global.whereis_name({__MODULE__, name}) do
      :undefined -> nil
      pid -> pid
    end
  end

  @spec init(Todo.Cache.cache_key) :: {:ok, {Todo.Cache.cache_key, nil}, {:continue, :init}}
  @impl true
  def init(name) do
    {:ok, {name, nil}, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, {name, nil}) do
    todo_list = Todo.Database.get(name) || Todo.List.new()
    {:noreply, {name, todo_list}, @expiry_idle_timeout}
  end

  def stop(pid) do
    GenServer.stop(pid, :normal)
  end

  @impl true
  def handle_call(request, _from, {name, todo_list}) do
    case request do
      {:entries, date} ->
        {
          :reply,
          Todo.List.entries(todo_list, date),
          {name, todo_list},
          @expiry_idle_timeout
        }
    end
  end

  @impl true
  def handle_cast(request, {name, todo_list}) do
    new_list =
      case request do
        {:add_entry, new_entry} ->
          Todo.List.add_entry(todo_list, new_entry)

        {:add_entries, new_entries} ->
          Todo.List.add_entries(todo_list, new_entries)

        {:update_entry, id, entry} ->
          Todo.List.update_entry(todo_list, id, entry)

        {:delete_entry, id} ->
          Todo.List.delete_entry(todo_list, id)

        {:reset_db} ->
          Todo.List.new()
      end

    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end

  @impl true
  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping to-do server for #{name}")
    {:stop, :normal, {name, todo_list}}     #1
  end


  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def add_entries(pid, new_entries) do
    GenServer.cast(pid, {:add_entries, new_entries})
  end

  def update_entry(pid, id, entry) do
    GenServer.cast(pid, {:update_entry, id, entry})
  end

  def delete_entry(pid, id) do
    GenServer.cast(pid, {:delete_entry, id})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def reset_db(pid) do
    GenServer.cast(pid, {:reset_db})
  end
end

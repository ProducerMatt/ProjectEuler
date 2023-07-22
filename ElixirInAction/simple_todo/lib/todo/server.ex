defmodule Todo.Server do
  @moduledoc """
  Todo List: state-maintaining server functions
  """
  use GenServer

  @spec start() :: {:ok, pid}
  @spec start(list()) :: {:ok, pid}
  def start(entries \\ []) do
    result = GenServer.start(__MODULE__, entries, name: __MODULE__)
    case result do
      {:ok, pid} -> {:ok, pid}
      x -> throw("Unexpected: #{x}")
    end
  end
  @impl GenServer
  @spec init(list()) :: {:ok, map}
  def init(entries) do
    {:ok,
     cond do
       length(entries) > 0 ->
         Todo.List.new(entries)
       true ->
         Todo.List.new()
     end
    }
  end
  @spec stop :: :ok
  def stop do
    GenServer.stop(__MODULE__, :normal)
  end

  @impl GenServer
  def handle_call(request, _from, todo_list) do
    case request do
      {:entries, date} ->
        {:reply, Todo.List.entries(todo_list, date), todo_list}
    end
  end
  @impl GenServer
  def handle_cast(request, todo_list) do
    case request do
      {:add_entry, new_entry} ->
        {:noreply, Todo.List.add_entry(todo_list, new_entry)}
      {:add_entries, new_entries} ->
        {:noreply, Todo.List.add_entries(todo_list, new_entries)}
      {:update_entry, id, entry} ->
        {:noreply, Todo.List.update_entry(todo_list, id, entry)}
      {:delete_entry, id} ->
        {:noreply, Todo.List.delete_entry(todo_list, id)}
    end
  end
  def add_entry(new_entry) do
    GenServer.cast(__MODULE__, {:add_entry, new_entry})
  end
  def add_entries(new_entries) do
    GenServer.cast(__MODULE__, {:add_entries, new_entries})
  end
  def update_entry(id, entry) do
    GenServer.cast(__MODULE__, {:update_entry, id, entry})
  end
  def delete_entry(id) do
    GenServer.cast(__MODULE__, {:delete_entry, id})
  end
  def entries(date) do
    GenServer.call(__MODULE__, {:entries, date})
  end
end

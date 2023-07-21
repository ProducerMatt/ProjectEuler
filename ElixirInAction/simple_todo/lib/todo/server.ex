defmodule Todo.Server do
  use GenServer

  @spec start(atom() | list()) :: pid
  def start(entries \\ nil) do
    result = GenServer.start(__MODULE__, entries, name: __MODULE__)
    case result do
      {:ok, pid} -> pid
      x -> "Unexpected: #{x}"
    end
  end
  @impl GenServer
  @spec init(atom() | list()) :: {:ok, map}
  def init(entries) do
    {:ok,
     cond do
       is_list(entries) ->
         Todo.List.new(entries)
       is_nil(entries) ->
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
      {:update_entry, id, entry} ->
        {:noreply, Todo.List.update_entry(todo_list, id, entry)}
      {:delete_entry, id} ->
        {:noreply, Todo.List.delete_entry(todo_list, id)}
    end
  end
  def add_entry(new_entry) do
    GenServer.cast(__MODULE__, {:add_entry, new_entry})
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

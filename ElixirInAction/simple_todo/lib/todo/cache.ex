defmodule Todo.Cache do
  @type cache_key :: String.t
  @type cache_map :: %{cache_key => pid}

  @spec init(any) :: {:ok, %{}}
  def init(_) do
    {:ok, %{}}
  end
  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    IO.puts("Starting to-do cache.")
    DynamicSupervisor.start_link(     #1
      name: __MODULE__,
      strategy: :one_for_one
    )
  end
  @spec server_process(cache_key) :: pid
  def server_process(todo_list_name) do
    existing_process(todo_list_name) || new_process(todo_list_name)
  end

  defp existing_process(todo_list_name) do
    Todo.Server.whereis(todo_list_name)
  end

  defp new_process(todo_list_name) do
    case DynamicSupervisor.start_child(
      __MODULE__,
      {Todo.Server, todo_list_name}
    ) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [nil]},
      type: :supervisor
    }
  end
  @spec handle_call({:server_process, cache_key}, any, cache_map) :: {:reply, pid, cache_map}
  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}
      :error ->
        {:ok, new_server} = Todo.Server.start_link(todo_list_name)
        {
          :reply,
          new_server,
          Map.put(todo_servers, todo_list_name, new_server)
        }
    end end
end

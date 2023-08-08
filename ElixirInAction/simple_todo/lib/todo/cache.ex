defmodule Todo.Cache do
  use GenServer
  @type cache_key :: String.t
  @type cache_map :: %{cache_key => pid}

  @spec init(any) :: {:ok, %{}}
  def init(_) do
    {:ok, %{}}
  end
  #def start_link(), do: start_link(nil)
  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    IO.puts("Starting to-do cache.")
    DynamicSupervisor.start_link(     #1
      name: __MODULE__,
      strategy: :one_for_one
    )
  end
  def server_process(todo_list_name) do
    case start_child(todo_list_name) do
      {:ok, pid} -> pid                    #1
      {:error, {:already_started, pid}} -> pid    #2
    end
  end
  defp start_child(todo_list_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Todo.Server, todo_list_name}
    )
  end
  @use DynamicSupervisor
  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [nil]},
      type: :supervisor
    } end
  @spec server_process(cache_key) :: pid
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

defmodule Todo.Cache do
  @type cache_key :: String.t
  @type cache_map :: %{cache_key => pid}

  def init(_) do
    _ = Todo.Database.start()
    {:ok, %{}}
  end
  def start do
    GenServer.start(__MODULE__, nil)
  end
  @spec server_process(atom | pid | {atom, any} | {:via, atom, any}, cache_key) :: pid
  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end
  @spec handle_call({:server_process, cache_key}, any, cache_map) :: {:reply, pid, cache_map}
  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}
      :error ->
        {:ok, new_server} = Todo.Server.start(todo_list_name)
        {
          :reply,
          new_server,
          Map.put(todo_servers, todo_list_name, new_server)
        }
    end end
end

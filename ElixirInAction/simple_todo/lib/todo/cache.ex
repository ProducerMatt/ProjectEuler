defmodule Todo.Cache do
  use GenServer
  @type cache_key :: String.t
  @type cache_map :: %{cache_key => pid}

  @spec init(any) :: {:ok, %{}}
  def init(_) do
    IO.puts("Starting to-do cache.")
    _ = Todo.Database.start_link()
    {:ok, %{}}
  end
  #def start_link(), do: start_link(nil)
  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end
  @spec server_process(cache_key) :: pid
  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
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

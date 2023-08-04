defmodule Todo.Database do
  alias Todo.DatabaseWorker
  use GenServer
  @db_folder "./persist"
  @num_workers 3

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    GenServer.start_link(__MODULE__, @num_workers, name: __MODULE__)
  end
  @spec store(String.t, any) :: :ok
  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end
  @spec get(String.t) :: any
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end
  @impl GenServer
  @spec init(non_neg_integer) :: {:ok, [pid]}
  def init(num_workers) do
    IO.puts("Starting to-do database.")
    pidlist = Enum.map(1..num_workers, fn _ ->
        {:ok, pid} = DatabaseWorker.start_link(@db_folder)
        pid
      end)
    {:ok, pidlist}
  end
  @spec choose_worker(String.t) :: non_neg_integer
  defp choose_worker(key) do
    :erlang.phash2(key, @num_workers)
  end
  @impl GenServer
  @spec handle_call({:get, String.t}, any, [pid]) :: {:reply, any, [pid]}
  def handle_call({:get, key}, _from, workers) do
    wid = Enum.at(workers, choose_worker(key))
    result = DatabaseWorker.get(wid, key)
    {:reply, result, workers}
  end
  @impl GenServer
  @spec handle_cast({:store, String.t, any}, [pid]) :: {:noreply, [pid]}
  def handle_cast({:store, key, data}, workers) do
    wid = Enum.at(workers, choose_worker(key))
    DatabaseWorker.store(wid, key, data)
    {:noreply, workers}
  end
end
defmodule Todo.DatabaseWorker do
  alias Todo.DatabaseWorker
  use GenServer

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(folder) do
    GenServer.start_link(DatabaseWorker, folder)
  end
  @spec store(pid, String.t, any) :: :ok
  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end
  @spec get(pid, String.t) :: any
  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end
  @impl GenServer
  @spec init(String.t) :: {:ok, String.t}
  def init(folder) do
    IO.puts("Starting to-do database worker.")
    File.mkdir_p!(folder)
    {:ok, folder}
  end
  @impl GenServer
  @spec handle_cast({:store, String.t, any}, String.t) :: {:noreply, String.t}
  def handle_cast({:store, key, data}, folder) do
    file_name(folder, key)
    |> File.write!(:erlang.term_to_binary(data))
    {:noreply, folder}
  end
  @impl GenServer
  @spec handle_call({:get, String.t}, any, String.t) :: {:reply, any, String.t}
  def handle_call({:get, key}, _, folder) do
    data = case File.read(file_name(folder, key)) do
             {:ok, contents} -> :erlang.binary_to_term(contents)
             _ -> nil
           end
    {:reply, data, folder}
  end
  @spec file_name(String.t, any) :: String.t
  defp file_name(folder, key) do
    Path.join([folder, to_string(key)])
  end
end

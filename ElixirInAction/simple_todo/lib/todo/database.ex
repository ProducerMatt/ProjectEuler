defmodule Todo.Database do
  alias Todo.DatabaseWorker
  use GenServer
  @db_folder "./persist"
  @num_workers 3
  def start() do
    GenServer.start(__MODULE__, @num_workers)
  end
  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end
  @impl GenServer
  @spec init(integer) :: {:ok, [pid]}
  def init(num_workers) do
    {:ok, Enum.map(1..num_workers, fn _ ->
        spawn(fn -> DatabaseWorker.start(@db_folder) end)
      end)}
  end
  defp choose_worker(key) do
    :erlang.phash2(key, @num_workers)
  end
  @impl GenServer
  def handle_call(request, _from, workers) do
    case request do
      {:get, key} ->
        wid = choose_worker(key)
        result = DatabaseWorker.get(workers[wid], key)
        {:reply, result, workers}
    end
  end
  @impl GenServer
  def handle_cast(request, workers) do
    case request do
      {:store, key, data} ->
        wid = choose_worker(key)
        DatabaseWorker.store(workers[wid], key, data)
        {:noreply, workers}
    end
  end
end
defmodule Todo.DatabaseWorker do
  use GenServer
  def start(folder) do
    GenServer.start(__MODULE__, folder)
  end
  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end
  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end
  @impl GenServer
  def init(folder) do
    File.mkdir_p!(folder)
    {:ok, folder}
  end
  @impl GenServer
  def handle_cast({:store, key, data}, folder) do
    key
    |> file_name(folder)
    |> File.write!(:erlang.term_to_binary(data))
    {:noreply, folder}
  end
  @impl GenServer
  def handle_call({:get, key}, _, folder) do
    data = case File.read(file_name(folder, key)) do
             {:ok, contents} -> :erlang.binary_to_term(contents)
             _ -> nil
           end
    {:reply, data, folder}
  end
  defp file_name(folder, key) do
    Path.join(folder, to_string(key))
  end
end

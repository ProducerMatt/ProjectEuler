defmodule Todo.Database do
  alias Todo.DatabaseWorker
  @db_folder "./persist"
  @num_workers 3

  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link do
    File.mkdir_p!(@db_folder)
    children = Enum.map(1..@num_workers, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end
  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end
  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end
  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end
  defp choose_worker(key) do
    :erlang.phash2(key, @num_workers) + 1
  end
  @spec init(non_neg_integer) :: {:ok, [pid]}
  def init(num_workers) do
    IO.puts("Starting to-do database.")
    pidlist = Enum.map(1..num_workers, fn wid ->
        {:ok, pid} = DatabaseWorker.start_link({@db_folder, wid})
        pid
      end)
    {:ok, pidlist}
  end
  def handle_call({:get, key}, _from, workers) do
    wid = elem(workers, choose_worker(key))
    result = DatabaseWorker.get(wid, key)
    {:reply, result, workers}
  end
  def handle_cast({:store, key, data}, workers) do
    wid = elem(workers, choose_worker(key))
    DatabaseWorker.store(wid, key, data)
    {:noreply, workers}
  end
end
defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link({db_folder, worker_id}) do
    GenServer.start_link(
      __MODULE__,
      db_folder,
      name: via_tuple(worker_id)
    )
  end
  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end
  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end
  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
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

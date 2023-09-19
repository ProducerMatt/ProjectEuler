defmodule Todo.Database do
  require :poolboy
  alias Todo.DatabaseWorker
  @num_workers 3
  @type cache_key :: Todo.Cache.cache_key
  @type workerlist_tuple :: {pid}
  @type data :: any

  def child_spec(_) do
    db_folder = Application.fetch_env!(:todo, :db_folder)
    File.mkdir_p!(db_folder)

    :poolboy.child_spec(
      __MODULE__,

      [
        name: {:local, __MODULE__},
        worker_module: DatabaseWorker,
        size: @num_workers,
        max_overflow: 1
      ],

      [db_folder]
    )
  end

  def store(key, data) do
    {_results, bad_nodes} =
      :rpc.multicall(
        __MODULE__,
        :store_local,
        [key, data],
        :timer.seconds(5)
      )
    Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))
    :ok
  end
  def store_local(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        DatabaseWorker.store(worker_pid, key, data)
      end
    )
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        DatabaseWorker.get(worker_pid, key)
      end
    )
  end

  def init(_) do
    IO.puts("Starting to-do database.")
  end

  def worker_pid(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        DatabaseWorker.pid(worker_pid, key)
      end
    )
  end
end

defmodule Todo.DatabaseWorker do
  @type cache_key :: Todo.Database.cache_key
  @type data :: Todo.Database.data
  use GenServer

  @type nn_int :: non_neg_integer

  def start_link(db_folder) do
    GenServer.start_link(__MODULE__, db_folder)
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def pid(pid, key) do
    GenServer.call(pid, {:pid, key})
  end

  @impl GenServer
  @spec init(String.t) :: {:ok, String.t}
  def init(folder) do
    IO.puts("Starting to-do database worker.")
    {:ok, folder}
  end
  @impl GenServer

  def handle_cast({:store, key, data}, folder) do
    file_name(folder, key)
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

  def handle_call({:pid, _}, _, folder) do
    {:reply, self(), folder}
  end

  @spec file_name(String.t, cache_key) :: String.t
  defp file_name(folder, key) do
    Path.join([folder, to_string(key)])
  end
end

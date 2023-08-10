defmodule Todo.Database do
  alias Todo.DatabaseWorker
  @db_folder "./persist"
  @num_workers 3
  @type cache_key :: Todo.Cache.cache_key
  @type workerlist_tuple :: {pid}
  @type data :: any

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

  @spec store(cache_key, data) :: :ok
  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  @spec get(cache_key) :: data
  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  @spec choose_worker(cache_key) :: pos_integer
  def choose_worker(key) do
    :erlang.phash2(key, @num_workers) + 1
  end

  @spec init(pos_integer) :: {:ok, [pid]}
  def init(num_workers) do
    IO.puts("Starting to-do database.")
    pidlist = Enum.map(1..num_workers, fn wid ->
        {:ok, pid} = DatabaseWorker.start_link({@db_folder, wid})
        pid
      end)
    {:ok, pidlist}
  end

  @spec worker_pid(cache_key) :: pid
  def worker_pid(key) do
    choose_worker(key)
    |> DatabaseWorker.pid()
  end
end

defmodule Todo.DatabaseWorker do
  @type cache_key :: Todo.Database.cache_key
  @type data :: Todo.Database.data
  @type via_tuple :: {:via, Registry, {Todo.ProcessRegistry, {Todo.DatabaseWorker, pos_integer}}}
  use GenServer

  @type nn_int :: non_neg_integer
  @spec wait_till_online(via_tuple, nn_int | {nn_int, nn_int}) :: true
  @doc """
    Check if the given via tuple matches a valid PID that's alive. If not,
    recurse until it's found, or until the max_tries are reached.
    NOTE: is this GenServer functionality I missed?
  """
  def wait_till_online(via_tuple, tries \\ 15) do
    if is_integer(tries) do
      wait_till_online(via_tuple, {tries, tries})
    else
      {max_tries, i} = tries
      pid = GenServer.whereis(via_tuple)
      if pid && Process.alive?(pid) do
        true
      else
        {_, _, {_, {_, worker_id}}} = via_tuple
        if (i > 0) do
          IO.puts("DatabaseWorker #{worker_id} not found, retrying")
          wait_till_online(via_tuple, {max_tries, i - 1})
        else
          throw("DatabaseWorker #{worker_id} couldn't be found after #{max_tries} tries")
        end
      end
    end
  end

  @spec start_link({String.t, pos_integer}) :: :ignore | {:error, any} | {:ok, pid}
  def start_link({db_folder, worker_id}) do
    GenServer.start_link(
      __MODULE__,
      db_folder,
      name: via_tuple(worker_id)
    )
  end

  @spec store(pos_integer, cache_key, data) :: :ok
  def store(worker_id, key, data) do
    via = via_tuple(worker_id)
    wait_till_online(via)
    GenServer.cast(via, {:store, key, data})
  end

  @spec get(pos_integer, cache_key) :: data
  def get(worker_id, key) do
    via = via_tuple(worker_id)
    wait_till_online(via)
    GenServer.call(via_tuple(worker_id), {:get, key})
  end
  @spec pid(pos_integer) :: pid
  def pid(worker_id) do
    via = via_tuple(worker_id)
    wait_till_online(via)
    GenServer.call(via_tuple(worker_id), :pid)
  end

  @spec via_tuple(pos_integer) :: via_tuple
  def via_tuple(worker_id) do
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
  def handle_call(:pid, _, folder) do
    {:reply, self(), folder}
  end

  @spec file_name(String.t, cache_key) :: String.t
  defp file_name(folder, key) do
    Path.join([folder, to_string(key)])
  end
end

defmodule SimpleRegistryGenserver do
  require Logger
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, Map.new()}
  end

  @impl true
  def handle_call({:whereis, name}, _from, state) do
    {:reply,
      Map.get(state, name), # default nil
      state}
  end
  @impl true
  def handle_cast({:register, name, pid}, state) do
    Process.link(pid)
    {:noreply, Map.put(state, name, pid)}
  end
  @impl true
  def handle_info({:EXIT, pid, _reason}, state) do
    new_state = Map.reject(state,
      fn {_, value} -> value == pid
    end)
    {:noreply, new_state}
  end

  def register(name) do
    GenServer.cast(__MODULE__, {:register, name, self()})
  end
  def whereis(name) do
    GenServer.call(__MODULE__, {:whereis, name})
  end
end

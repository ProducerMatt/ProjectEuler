defmodule SimpleRegistryETS do
  require Logger
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, :ets.new(__MODULE__, [:named_table, :public, :set, write_concurrency: true])}
  end

  @impl true
  def handle_info({:EXIT, pid, _reason}, state) do
    :ets.match_delete(__MODULE__, {:_, pid})
    {:noreply, state}
  end

  def register(name) do
    Process.flag(:trap_exit, true)
    Process.link(GenServer.whereis(__MODULE__))
    :ets.insert_new(__MODULE__, {name, self()})
  end
  def whereis(name) do
    case :ets.lookup(__MODULE__, name) do
      [{_, pid}] -> pid
      [] -> nil
    end
  end
end

defmodule Catcher do
  use GenServer

  def start_link(_ \\ nil) do
    GenServer.start_link(__MODULE__, nil)
  end

  def catch_this(data, pid) do
    GenServer.call(pid, {:catch, data}, :timer.seconds(3))
  end

  def keep_this(data, pid) do
    GenServer.call(pid, {:keep, data}, :timer.seconds(3))
  end

  def clear(pid) do
    GenServer.call(pid, :clear)
  end

  @impl GenServer
  def init(_) do
    {:ok, {nil, []}}
  end

  @impl GenServer
  def handle_call({:catch, data}, _from, {_temp, keep}) do
    {:reply, :ok, {data, keep}}
  end

  def handle_call({:keep, new_data}, _from, {temp, keep}) do
    {:reply, :ok, {temp, [new_data | keep]}}
  end

  def handle_call(:clear, _from, {temp, _keep}) do
    {:reply, :ok, {temp, []}}
  end

  def stop(pid) do
    GenServer.stop(pid)
  end
end

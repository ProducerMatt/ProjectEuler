defmodule Todo.System do
  ## Simple start
  #@spec start_link :: {:error, any} | {:ok, pid}
  #def start_link do
  #  Supervisor.start_link(
  #    [Todo.Cache],
  #    strategy: :one_for_one
  #  ) end

  # Advanced start, allows you to hot-reload modify the list of children without
  # restarting the server
  use Supervisor

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  @impl Supervisor
  def init(_) do
    Supervisor.init(
      [
        Todo.Cache,
        Todo.Database
      ],
      strategy: :one_for_one
    )
  end

  def stop do
    Supervisor.stop(__MODULE__)
  end
end

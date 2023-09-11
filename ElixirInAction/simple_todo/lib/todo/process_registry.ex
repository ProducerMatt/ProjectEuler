defmodule Todo.ProcessRegistry do
  @type via_tuple :: {:via, Registry, {Todo.ProcessRegistry, any}}

  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end
  @spec via_tuple(any) :: via_tuple
  def via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end
  @spec child_spec(any) :: %{
          :id => any,
          :start => {atom, atom, list},
          optional(:modules) => :dynamic | [atom],
          optional(:restart) => :permanent | :temporary | :transient,
          optional(:shutdown) => :brutal_kill | :infinity | pos_integer,
          optional(:type) => :supervisor | :worker
        }
  @use Supervisor
  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end
end

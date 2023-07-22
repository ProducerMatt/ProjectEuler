defmodule MultiDict do
  @moduledoc """
  Maintains a dictionary of lists that you cons to
  """
  @type t_empty :: %{}
  @type t_used :: %{any => list(any)}
  @type t :: t_empty() | t_used()

  @spec new :: t_empty
  def new(), do: %{}
  @spec add(t, any, any) :: t_used
  def add(dict, key, value) do
    Map.update(dict, key, [value], &[value | &1])
  end
  @spec get(t_used, any) :: any
  def get(dict, key) do
    Map.get(dict, key, [])
  end
end

defmodule MultiDict do
  @moduledoc """
  Maintains a dictionary of lists that you cons to
  """
  @type t :: %{} | %{any => list(any)}
  @spec new :: MultiDict.t
  def new(), do: %{}
  @spec add(MultiDict.t, any, any) :: MultiDict.t
  def add(dict, key, value) do
    Map.update(dict, key, [value], &[value | &1])
  end
  @spec get(MultiDict.t, any) :: any
  def get(dict, key) do
    Map.get(dict, key, [])
  end
end

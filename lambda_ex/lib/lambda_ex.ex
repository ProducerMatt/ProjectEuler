defmodule LambdaEx do
  alias MapSet, as: S

  def eval(c, {:apply, {:lambda, v, inner}, outer}) do
    [{v, outer} | c]
    |> eval(inner)
  end

  def eval(c, {:let, lets, e}) do
    Enum.concat(lets, c)
    |> eval(e)
  end

  def eval(c, v) when is_atom(v), do: Keyword.get(c, v, v)

  def eval(_c, l = {:lambda, _v, _inner}), do: l

  def fv(v) when is_atom(v), do: S.new([v])

  def fv({:apply, e1, e2}) do
    fv(e1)
    |> S.union(fv(e2))
  end

  def fv({:lambda, v, e}) do
    fv(e)
    |> S.delete(v)
  end

  def fv({:let, lets, e}) do
    assigned =
      Keyword.keys(lets)
      |> S.new()

    fv(e)
    |> S.difference(assigned)
  end
end

defmodule LambdaEx do
  require LambdaEx
  alias MapSet, as: S

  defguard is_var(v) when is_atom(v)
  defguard is_var_list(v) when is_list(v)
  defguard is_expr_list(v) when is_list(v)

  def eval(c, v) when is_var(v), do: Keyword.get(c, v, v)

  def eval(c, l = {:lambda, v, inner}), do: {:lambda, v, eval(c, inner)}

  def eval(c, {:apply, l = {:lambda, _v, _inner}, []}), do: eval(c, l)

  def eval(c, {:apply, {:lambda, vars, inner}, outers}) when is_var_list(vars) and is_expr_list(outers) do
    next_c = [{v1, o1} | c]

    case {v2, o2} do
      {[], []} ->
        eval(next_c, inner)
      {[], _} ->
        raise "Applying to nothing!"
      {more_vars, []} ->
        eval(next_c, {:lambda, more_vars, inner})
      {more_vars, more_apps} ->
        eval(next_c, {:apply, {:lambda, more_vars, inner}, more_apps})
    end
  end

  def eval(c, {:let, lets, e}) do
    Enum.concat(lets, c)
    |> eval(e)
  end

  def fv(v) when is_var(v), do: S.new([v])

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

defmodule Math do
  def fib(0), do: 1
  def fib(1), do: 1
  def fib(x) when is_integer(x), do: fib(x - 1) + fib(x - 2)
end

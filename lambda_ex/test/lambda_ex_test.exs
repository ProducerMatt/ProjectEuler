defmodule LambdaExTest do
  use ExUnit.Case
  doctest LambdaEx
  import AssertValue

  test "basic lambda calculus" do
    id = {:lambda, :x, :x}
    assert LambdaEx.eval([], id) == id
    assert LambdaEx.eval([], {:apply, id, :y}) == :y
    assert LambdaEx.eval([], {:apply, id, id}) == id
    assert LambdaEx.eval([], {:let, [x: 1], {:apply, {:lambda, :y, :x}, nil}}) == 1
  end

  test "free variables" do
    id = {:lambda, :x, :x}
    assert_value LambdaEx.fv(id) == MapSet.new([])
    assert_value LambdaEx.fv({:lambda, :x, :y}) == MapSet.new([:y])
    assert_value LambdaEx.fv({:apply, id, :y}) == MapSet.new([:y])
    assert_value LambdaEx.fv({:apply, id, id}) == MapSet.new([])

    assert_value LambdaEx.fv({:let, [x: :z], {:apply, {:lambda, :y, :x}, :w}}) ==
                   MapSet.new([:w])
  end
end

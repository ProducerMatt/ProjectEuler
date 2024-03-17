defmodule ExrTest do
  use ExUnit.Case
  doctest Exr

  test "greets the world" do
    assert Exr.hello() == :world
  end
end

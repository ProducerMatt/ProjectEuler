defmodule SimpleRegistryETSTest do
  use ExUnit.Case
  doctest SimpleRegistryETS

  describe "SimpleRegistry" do
    test "clear when exits" do
      SimpleRegistryETS.start_link()
      f = spawn(fn  ->
        SimpleRegistryETS.register(:f)
        receive do
          _ -> nil
        end
      end)
      Process.sleep(50)
      assert f == SimpleRegistryETS.whereis(:f)
      send(f, nil)
      Process.sleep(50)
      assert Process.alive?(f) == false
      assert SimpleRegistryETS.whereis(:f) == nil
    end
  end
end

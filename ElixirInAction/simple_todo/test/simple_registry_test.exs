defmodule SimpleRegistryTest do
  use ExUnit.Case
  doctest SimpleRegistry

  describe "SimpleRegistry" do
    test "clear when exits" do
      SimpleRegistry.start_link()
      f = spawn(fn  ->
        SimpleRegistry.register(:f)
        receive do
          _ -> nil
        end
      end)
      Process.sleep(50)
      assert f == SimpleRegistry.whereis(:f)
      send(f, nil)
      Process.sleep(50)
      assert Process.alive?(f) == false
      assert SimpleRegistry.whereis(:f) == nil
    end
  end
end

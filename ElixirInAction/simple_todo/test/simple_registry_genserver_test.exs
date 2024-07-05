defmodule SimpleRegistryGenserverTest do
  use ExUnit.Case
  doctest SimpleRegistryGenserver

  describe "SimpleRegistry" do
    test "clear when exits" do
      SimpleRegistryGenserver.start_link()
      f = spawn(fn  ->
        SimpleRegistryGenserver.register(:f)
        receive do
          _ -> nil
        end
      end)
      Process.sleep(50)
      assert f == SimpleRegistryGenserver.whereis(:f)
      send(f, nil)
      Process.sleep(50)
      assert Process.alive?(f) == false
      assert SimpleRegistryGenserver.whereis(:f) == nil
    end
  end
end

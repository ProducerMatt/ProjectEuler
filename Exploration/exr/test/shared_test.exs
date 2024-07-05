defmodule SharedTest do
  use ExUnit.Case

  test "cross_product" do
    answer = [{1, :a}, {1, :b}, {2, :a}, {2, :b}]
    gen = Shared.cross_product([[1, 2], [:a, :b]])
    assert Enum.sort(gen) == Enum.sort(answer)
    answer = [{1, :a}]
    gen = Shared.cross_product([[1], [:a]])
    assert Enum.sort(gen) == Enum.sort(answer)
    answer = [{1, :a, :x}, {1, :a, :y}, {1, :b, :x}, {1, :b, :y}, {2, :a, :x}, {2, :a, :y}, {2, :b, :x}, {2, :b, :y}]
    gen = Shared.cross_product([[1, 2], [:a, :b], [:x, :y]])
    assert Enum.sort(gen) == Enum.sort(answer)
    answer = [
      {:a, 1, :x, false},
      {:a, 1, :x, true},
      {:a, 1, :y, false},
      {:a, 1, :y, true},
      {:a, 2, :x, false},
      {:a, 2, :x, true},
      {:a, 2, :y, false},
      {:a, 2, :y, true},
      {:a, 3, :x, false},
      {:a, 3, :x, true},
      {:a, 3, :y, false},
      {:a, 3, :y, true},
      {:a, 4, :x, false},
      {:a, 4, :x, true},
      {:a, 4, :y, false},
      {:a, 4, :y, true},
      {:b, 1, :x, false},
      {:b, 1, :x, true},
      {:b, 1, :y, false},
      {:b, 1, :y, true},
      {:b, 2, :x, false},
      {:b, 2, :x, true},
      {:b, 2, :y, false},
      {:b, 2, :y, true},
      {:b, 3, :x, false},
      {:b, 3, :x, true},
      {:b, 3, :y, false},
      {:b, 3, :y, true},
      {:b, 4, :x, false},
      {:b, 4, :x, true},
      {:b, 4, :y, false},
      {:b, 4, :y, true}
    ]
    gen = Shared.cross_product([[:a, :b], [1, 2, 3, 4], [:x, :y], [false, true]])
    assert Enum.sort(gen) == Enum.sort(answer)
  end

  test "cross_product_stream" do
    answer = [{1, :a}, {1, :b}, {2, :a}, {2, :b}]
    gen = Shared.cross_product_stream([[1, 2], [:a, :b]])
    assert Enum.sort(gen) == Enum.sort(answer)
    answer = [{1, :a}]
    gen = Shared.cross_product_stream([[1], [:a]])
    assert Enum.sort(gen) == Enum.sort(answer)
    answer = [{1, :a, :x}, {1, :a, :y}, {1, :b, :x}, {1, :b, :y}, {2, :a, :x}, {2, :a, :y}, {2, :b, :x}, {2, :b, :y}]
    gen = Shared.cross_product_stream([[1, 2], [:a, :b], [:x, :y]])
    assert Enum.sort(gen) == Enum.sort(answer)
    answer = [
      {:a, 1, :x, false},
      {:a, 1, :x, true},
      {:a, 1, :y, false},
      {:a, 1, :y, true},
      {:a, 2, :x, false},
      {:a, 2, :x, true},
      {:a, 2, :y, false},
      {:a, 2, :y, true},
      {:a, 3, :x, false},
      {:a, 3, :x, true},
      {:a, 3, :y, false},
      {:a, 3, :y, true},
      {:a, 4, :x, false},
      {:a, 4, :x, true},
      {:a, 4, :y, false},
      {:a, 4, :y, true},
      {:b, 1, :x, false},
      {:b, 1, :x, true},
      {:b, 1, :y, false},
      {:b, 1, :y, true},
      {:b, 2, :x, false},
      {:b, 2, :x, true},
      {:b, 2, :y, false},
      {:b, 2, :y, true},
      {:b, 3, :x, false},
      {:b, 3, :x, true},
      {:b, 3, :y, false},
      {:b, 3, :y, true},
      {:b, 4, :x, false},
      {:b, 4, :x, true},
      {:b, 4, :y, false},
      {:b, 4, :y, true}
    ]
    gen = Shared.cross_product_stream([[:a, :b], [1, 2, 3, 4], [:x, :y], [false, true]])
    assert Enum.sort(gen) == Enum.sort(answer)
  end

  test "jobs_plus_inputs" do
    j1 = fn input ->
      input + 1
    end
    j2 = fn input ->
      input + 2
    end
    jobs = %{
      "a" => j1,
      "b" => j2,
    }

    i1 = fn -> 3 end
    i2 = fn _ -> 4 end
    inputs = %{
      "x" => i1,
      "y" => i2
    }

    answer = %{
      "a with x" => {j1, before_scenario: i1},
      "a with y" => {j1, before_scenario: i2},
      "b with x" => {j2, before_scenario: i1},
      "b with y" => {j2, before_scenario: i2}
    }
    gen = Shared.jobs_plus_inputs(jobs, inputs)

    resolve_funcs = fn suite ->
      Map.new(suite, fn {name, {j, before_scenario: i}} ->
        case Function.info(i, :arity) do
          {:arity, 0} ->
            {name, j.(i.())}
          {:arity, 1} ->
            {name, j.(i.(Benchee.Benchmark.no_input()))}
        end
      end)
    end

    assert resolve_funcs.(answer) == resolve_funcs.(gen)
  end
end

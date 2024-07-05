defmodule Shared do
  use TypeCheck

  def into_tuple(x, tup) when is_tuple(tup), do: Tuple.insert_at(tup, 0, x)
  def into_tuple(x, y), do: {x, y}

  def cross_product(ll, f \\ &into_tuple/2) when is_list(ll) and is_function(f, 2) do
    List.foldr(ll, [], fn
      l, [] ->
        l
      l1, l2 ->
        do_cross_product(l1, l2, f)
    end)
  end

  defp do_cross_product(l1, l2, f) when is_function(f, 2) do
    Enum.flat_map(l1, fn x ->
      Enum.map(l2, fn y ->
        f.(x, y)
      end)
    end)
  end

  def cross_product_stream(ll, f \\ &into_tuple/2) when is_function(f, 2) do
    Enum.to_list(ll)
    |> List.foldr([], fn
      l, [] ->
        l
      l1, l2 ->
        do_cross_product_stream(l1, l2, f)
    end)
  end

  defp do_cross_product_stream(l1, l2, f) when is_function(f, 2) do
    Stream.flat_map(l1, fn x ->
      Stream.map(l2, fn y ->
        f.(x, y)
      end)
    end)
  end


  @doc "Benchee convenience, takes jobs and input functions, cross products and returns jobs with inputs as before_scenarios"
  @spec! jobs_plus_inputs(jobs :: map(name :: String.t(), func :: (any() -> any())), inputs :: map(name :: String.t(), func :: (any() -> any()) | (-> any()))) :: map(name :: String.t(), {job :: (any() -> any()), before_scenario: input :: (any() -> any())})
  def jobs_plus_inputs(jobs, inputs) do
    no_input = Benchee.Benchmark.no_input()

    cross_product([jobs, inputs], fn
      {job_name, job_func}, {input_name, input_func} ->
        input_func_wrapped = case Function.info(input_func, :arity) do
          {:arity, 0} -> 
            fn ^no_input -> input_func.() end
          {:arity, 1} -> 
            input_func
        end
        {"#{job_name} with #{input_name}", {job_func, before_scenario: input_func_wrapped}}
    end)
    |> Map.new()
  end
end

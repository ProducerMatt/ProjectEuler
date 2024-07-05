defmodule Q002 do
  @moduledoc """
  Message send performance, *not inclusive* of string conversion time

  Conclusion: blobs are *definitely* faster.

  Name                      ips        average  deviation         median         99th %
  small blob            96.93 K       10.32 μs   ±345.14%        9.61 μs       25.54 μs
  small strings         82.17 K       12.17 μs   ±308.75%       11.19 μs       29.42 μs
  small charlist        72.35 K       13.82 μs   ±433.05%       12.15 μs       30.83 μs
  small iolists         66.48 K       15.04 μs   ±653.16%       12.43 μs       29.51 μs
  medium blob           66.05 K       15.14 μs    ±65.74%       13.45 μs       35.02 μs
  medium strings        42.21 K       23.69 μs    ±73.00%       21.44 μs       53.52 μs
  medium iolists        31.57 K       31.67 μs   ±200.11%       28.68 μs       63.03 μs
  large blob            15.98 K       62.57 μs    ±13.55%       58.01 μs       97.30 μs
  medium charlist       13.70 K       73.00 μs   ±112.62%       68.03 μs      112.13 μs
  large iolists          5.19 K      192.72 μs     ±9.98%      189.98 μs      267.39 μs
  large strings          4.10 K      243.95 μs    ±90.62%      197.17 μs      791.03 μs
  large charlist       0.0520 K    19227.72 μs    ±21.74%    19503.15 μs    27963.84 μs
  """
  def bench() do
    %{
        "small charlist" => {
          &send_stuff/1, before_each: fn _ ->
          make_charlists(10)
        end},
        "medium charlist" => {
          &send_stuff/1, before_each: fn _ ->
          make_charlists(100)
        end},
        "large charlist" => {
          &send_stuff/1, before_each: fn _ ->
          make_charlists(1000)
        end},
        "small strings" => {
          &send_stuff/1, before_each: fn _ ->
          make_charlists(10) |> to_binaries()
        end},
        "medium strings" => {
          &send_stuff/1, before_each: fn _ ->
          make_charlists(100) |> to_binaries
        end},
        "large strings" => {
          &send_stuff/1, before_each: fn _ ->
          make_charlists(1000) |> to_binaries
        end},
        "small iolists" => {
          &send_stuff/1, before_each: fn _ ->
          make_charlists(10) |> to_nested_binaries()
        end},
        "medium iolists" => {
          &send_stuff/1, before_each: fn _ ->
          make_charlists(100) |> to_nested_binaries
        end},
        "large iolists" => {
          &send_stuff/1, before_each: fn _ ->
          make_charlists(1000) |> to_nested_binaries
        end},
        "small blob" => {
          &send_stuff/1, before_each: fn _ ->
          make_charlists(10) |> to_blob()
        end},
        "medium blob" => {
          &send_stuff/1, before_each: fn _ ->
          make_charlists(100) |> to_blob()
        end},
        "large blob" => {
          &send_stuff/1, before_each: fn _ ->
          make_charlists(1000) |> to_blob()
        end}
    }
    |> Benchee.run(
      time: 40,
      reduction_time: 10,
      memory_time: 3,
      pre_check: true,
      measure_function_call_overhead: true,
      formatters: [
        Benchee.Formatters.Console,
      ]
    )
  end

  def make_charlists(max_len) do
    for n <- 1..max_len do
      for _ <- 1..n do
        ~c"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
        |> Enum.random()
      end
    end
  end

  def to_binaries(ls) do
    for cl <- ls do
      to_string(cl)
    end
  end

  def to_nested_binaries(ls) do
    ls
    |> to_binaries()
    |> do_to_nested_binaries()
  end

  defp do_to_nested_binaries(ls) when is_list(ls) do
    funcs = [
      fn x, rest -> [x|rest] end,
      fn x, rest -> [[x]|rest] end,
      fn x, rest -> [x, rest] end,
      fn x, rest -> [[x], rest] end,
      fn x, rest -> [rest, x] end,
      fn x, rest -> [rest, [x]] end,
      fn x, rest -> [rest|x] end
    ]

    Enum.reduce(ls, fn
      x, acc ->
        apply(Enum.random(funcs), [x, acc])
    end)
  end

  def to_blob(ls) do
    IO.iodata_to_binary(ls)
  end

  def send_stuff(stuff) do
    {:ok, child} = Catcher.start_link()

    stuff
    |> Catcher.catch_this(child)

    :ok = Catcher.stop(child)
  end
end

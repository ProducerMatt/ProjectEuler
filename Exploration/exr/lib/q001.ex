defmodule Q001 do
  @moduledoc """
  Message send performance, *inclusive* of string conversion time

  Conclusion: When regularly converting, blobs are faster except in extreme sizes.

  Name                      ips        average  deviation         median         99th %
  small blob            89.32 K       11.20 μs   ±317.72%       10.26 μs       28.28 μs
  small charlist        73.79 K       13.55 μs   ±311.30%       12.65 μs       31.18 μs
  small strings         64.18 K       15.58 μs   ±316.73%       13.70 μs       32.66 μs
  small iolists         54.06 K       18.50 μs   ±343.91%       16.15 μs       36.03 μs
  medium blob           23.33 K       42.87 μs   ±114.06%       39.95 μs       77.20 μs
  medium strings        13.10 K       76.36 μs   ±155.87%       64.31 μs      143.87 μs
  medium iolists        10.01 K       99.86 μs    ±49.38%       90.50 μs      160.61 μs
  medium charlist        9.93 K      100.67 μs   ±142.46%       93.37 μs      140.03 μs
  large iolists        0.0977 K    10234.04 μs    ±17.61%     9814.61 μs    16460.94 μs
  large strings        0.0877 K    11397.02 μs    ±10.58%    11165.23 μs    17348.40 μs
  large blob           0.0864 K    11577.71 μs    ±24.57%    13269.71 μs    21455.74 μs
  large charlist       0.0253 K    39546.58 μs    ±12.27%    41927.98 μs    56285.70 μs
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
          &(to_binaries(&1) |> send_stuff()), before_each: fn _ ->
          make_charlists(10)
        end},
        "medium strings" => {
          &(to_binaries(&1) |> send_stuff()), before_each: fn _ ->
          make_charlists(100)
        end},
        "large strings" => {
          &(to_binaries(&1) |> send_stuff()), before_each: fn _ ->
          make_charlists(1000)
        end},
        "small iolists" => {
          &(to_nested_binaries(&1) |> send_stuff()), before_each: fn _ ->
          make_charlists(10)
        end},
        "medium iolists" => {
          &(to_nested_binaries(&1) |> send_stuff()), before_each: fn _ ->
          make_charlists(100)
        end},
        "large iolists" => {
          &(to_nested_binaries(&1) |> send_stuff()), before_each: fn _ ->
          make_charlists(1000)
        end},
        "small blob" => {
          &(to_blob(&1) |> send_stuff()), before_each: fn _ ->
          make_charlists(10)
        end},
        "medium blob" => {
          &(to_blob(&1) |> send_stuff()), before_each: fn _ ->
          make_charlists(100)
        end},
        "large blob" => {
          &(to_blob(&1) |> send_stuff()), before_each: fn _ ->
          make_charlists(1000)
        end}
    }
    |> Benchee.run(
      time: 40,
      reduction_time: 10,
      memory_time: 3,
      pre_check: true,
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
    |> Catcher.catch_f(&IO.iodata_to_binary/1, child)

    :ok = Catcher.stop(child)
  end
end

defmodule Q001 do
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

  defp do_to_nested_binaries(item) when not is_list(item) do
    if :rand.uniform(2) - 1 == 0 do
      [item]
    else
      item
    end
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

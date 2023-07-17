defmodule LargeLines do
  @moduledoc """
  Documentation for `LargeLines`.
  """

  @spec run(String.t) :: :done
  def run(testfile \\ "./test_file.md") do
    Enum.each([
      &large_lines!/1,
      &lines_lengths!/1,
      &longest_line_length!/1,
      &words_per_line!/1
    ],
      fn f -> IO.inspect(f.(testfile)) end)

    :done
  end

  @spec getvals(any) :: nonempty_list
  def getvals(testfile \\ "./test_file.md") do
    Enum.map([
      &large_lines!/1,
      &lines_lengths!/1,
      &longest_line_length!/1,
      &words_per_line!/1
    ],
      fn f -> f.(testfile) end)
  end

  @spec large_lines!(String.t) :: [] | nonempty_list(String.t)
  @doc """
  Takes a filename and returns the list of all lines from that file that are longer than 80 characters
  """
  def large_lines!(path) do
    File.stream!(path)
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    |> Enum.filter(&(String.length(&1) > 80))
  end

  @spec lines_lengths!(String.t) :: [] | nonempty_list(String.t)
  def lines_lengths!(path) do
    File.stream!(path)
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    |> Enum.map(&String.length(&1))
  end

  @spec longest_line_length!(String.t) :: [] | integer
  def longest_line_length!(path) do
    { longest_len, _str } = File.stream!(path)
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    |> Enum.reduce(
      {0, ""},
      fn str, acc ->
        len = String.length(str)
        if elem(acc, 0) < len do
          {len, str}
        else
          acc
        end
      end)
    longest_len
  end

  @spec words_per_line!(String.t) :: [] | nonempty_list(integer)
  def words_per_line!(path) do
    File.stream!(path)
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    |> Enum.map(fn str ->
      list = String.split(str)
      length(list)
    end)
  end
end

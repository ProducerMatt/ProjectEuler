defmodule LargeLinesTest do
  use ExUnit.Case
  doctest LargeLines

  @testfile "./test_file.md"

  test "large_lines!" do
    valid_data = ["If you get stuck on the exercise, check out `HINTS.md`, but try and solve it without using those first :)"]
    assert(LargeLines.large_lines!(@testfile) == valid_data)
  end
  test "lines_lengths!" do
    valid_data = [21, 0, 58, 80, 105, 0, 15, 0, 5, 0, 72]
    assert(LargeLines.lines_lengths!(@testfile) == valid_data)
  end
  test "longest_line_length!" do
    valid_data = 105
    assert(LargeLines.longest_line_length!(@testfile) == valid_data)
  end
  test "words_per_line!" do
    valid_data = [4, 0, 9, 14, 20, 0, 2, 0, 2, 0, 12]
    assert(LargeLines.words_per_line!(@testfile) == valid_data)
  end
    #Enum.each([
    #  &large_lines!/1,
    #  &lines_lengths!/1,
    #  &longest_line_length!/1,
    #  &words_per_line!/1
    #],
end

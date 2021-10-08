# random = ""
# alphabet = "C:\\Users\\benja\\Documents\\Bin\\elixir\\Chapter3\\textfiles\\alphabet.txt"

defmodule MyStream do
    @random_text "C:\\Users\\benja\\Documents\\Bin\\elixir\\Chapter3\\textfiles\\random.txt"
    @bible "C:\\Users\\benja\\Documents\\Bin\\elixir\\Chapter3\\textfiles\\bible.txt"

    def random_file(), do: @random_text
    def bible_file(), do: @bible

    def lines_length!(path \\ @random_text) do
        File.stream!(path)
        |> Stream.map(&String.replace(&1, "\n", ""))
        |> Enum.map(&String.length(&1))
    end

    def longest_line_length!(path \\ @random_text) do
        lines_length!(path)
        |> Enum.reduce(
            fn
                length, max when length >= max -> length
                _, max -> max
            end
        )
    end

    def longest_line!(path \\ @random_text) do
        {word, _} = File.stream!(path)
        |> Stream.map(&String.replace(&1, "\n", ""))
        |> Enum.with_index()
        |> Enum.reduce(
            fn {el, idx}, {maxEl, maxIdx} ->
                if String.length(el) >= String.length(maxEl) do
                    {el, idx}
                else
                    {maxEl, maxIdx}
                end
            end
        )
        word
    end

    def words_per_line!(path \\ @bible) do
        File.stream!(path)
        |> Stream.map(&String.replace(&1, "\n", ""))
        |> Enum.map(&length(String.split(&1, " ")))
    end
end
defmodule MyList do
    # Computes the length of a list
    def list_len(list) do
        do_len(0, list)
    end
    # Returns length when list matches []
    defp do_len(current_length, []) do
        current_length
    end
    # computes length via tail-recursion when list matches [head|tail]
    defp do_len(current_length, [_|tail]) do
        do_len(current_length + 1, tail)
    end

    # Return a reverse range of all integers between from and to
    def reverse_range(from, to) do
        reverse([], range(from, to))
    end

    # Return a list of all integers between from and to
    def range(from, to) when from == to do
        do_range([], from, to)
    end
    def range(from, to) when from < to do
        do_range([to|[]], from, to - 1)
    end
    def range(from, to) when from > to do
        do_range([from|[]], to, from - 1)
    end
    defp do_range(current_list, from, to) when from < to do
        do_range([to|current_list], from, to - 1)
    end
    defp do_range(current_list, from, to) when from == to do
        [from|current_list]
    end

    # Find all positive integers in reverse order of appearance
    def reverse_positive(list) do
        do_positive([], list)
    end

    # Find all positive integers in the list in order of appearance
    def positive(list) do
        reverse([], do_positive([], list))
    end
    defp do_positive(current_list, []) do
        current_list
    end
    defp do_positive(current_list, [head|tail]) do
        if is_number(head) and head >= 0 do
            do_positive([head | current_list], tail)
        else
            do_positive(current_list, tail)
        end
    end

    defp reverse(current_list, []) do
        current_list
    end
    defp reverse(current_list, [head|tail]) do
        reverse([head | current_list], tail)
    end
end

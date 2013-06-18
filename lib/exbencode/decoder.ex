defmodule Exbencode.Decoder do
  defmodule Strings do
    def decode(str) do
      [_, length_str] = Regex.run(%r/^([0-9]+):/, str)
      {length, ""} = String.to_integer(length_str)
      <<length_str, ?:, string::[binary, size(length)], rest::binary>> = str
      {string, rest}
    end
  end

  defmodule Integers do
    def decode(<<?-, rest::binary>>, acc, :start) do
      {number, rest} = decode(rest, acc, :number)
      {number * -1, rest}
    end

    def decode(<<?e, rest::binary>>, acc, _) do
      {acc, rest}
    end

    def decode(<<digit::utf8, rest::binary>>, acc, _) when digit >= ?0 and digit <= ?9 do
      decode(rest, acc*10 + (digit - ?0), :number)
    end
  end

  defmodule Lists do
    def decode(<<?e, rest::binary>>, acc) do
      {Enum.reverse(acc), rest}
    end

    def decode(<<rest::binary>>, acc) do
      {val, rest} = Exbencode.decode(rest)
      decode(rest, [val | acc])
    end
  end

  defmodule Dictionaries do
    def decode(<<?e, rest::binary>>, acc, _) do
      {Enum.reverse(acc), rest}
    end

    def decode(<<rest::binary>>, acc, last_key) do
      {<<key::binary>>, rest} = Exbencode.decode(rest)
      {value, rest} = Exbencode.decode(rest)

      # Keys must be sorted in ascending order:
      true = (key > last_key)

      acc = Dict.put_new(acc, binary_to_atom(key), value)
      decode(rest, acc, key)
    end
  end

  def decode(str = <<first::size(8), _::binary>>) when ?0 <= first and first <= ?9 do
    Strings.decode(str)
  end

  def decode(<<?i, rest::binary>>) do
    Integers.decode(rest, 0, :start)
  end

  def decode(<<?l, rest::binary>>) do
    Lists.decode(rest, [])
  end

  def decode(<<?d, rest::binary>>) do
    Dictionaries.decode(rest, [], "")
  end
end
defmodule Exbencode.Decoder do
  defmodule Strings do
    def decode(str) do
      [_, length_str] = Regex.run(%r/^([0-9]+):/, str)
      {length, ""} = String.to_integer(length_str)
      length_str_len = byte_size(length_str)
      if byte_size(str) < length_str_len + 1 + length do
        throw(:incomplete)
      end
      <<^length_str::[binary, size(length_str_len)], ":",
      string::[binary, size(length)], rest::binary>> = str
      {string, rest}
    end
  end

  defmodule Integers do
    def decode(<<>>, acc, _), do: throw(:incomplete)

    def decode(<<?-, rest::binary>>, acc, :start) do
      {number, rest} = decode(rest, acc, :number)
      {number * -1, rest}
    end

    def decode(<<?e, rest::binary>>, acc, _) do
      {acc, rest}
    end

    def decode(<<digit::utf8, rest::binary>>, acc, _)
    when digit >= ?0 and digit <= ?9 do
      decode(rest, acc*10 + (digit - ?0), :number)
    end
  end

  defmodule Lists do
    def decode(<<>>, acc), do: throw(:incomplete)

    def decode(<<?e, rest::binary>>, acc) do
      {Enum.reverse(acc), rest}
    end

    def decode(<<rest::binary>>, acc) do
      {val, rest} = Exbencode.Decoder.decode_simple(rest)
      decode(rest, [val | acc])
    end
  end

  defmodule Dictionaries do
    def decode(<<>>, acc, _), do: throw(:incomplete)

    def decode(<<?e, rest::binary>>, acc, _) do
      {acc, rest}
    end

    def decode(<<rest::binary>>, acc, last_key) do
      {<<key::binary>>, rest} = Exbencode.Decoder.decode_simple(rest)
      {value, rest} = Exbencode.Decoder.decode_simple(rest)

      # Keys must be sorted in ascending order:
      true = (key > last_key)

      acc = Dict.put_new(acc, binary_to_atom(key), value)
      decode(rest, acc, key)
    end
  end

  def decode(iolist = [_|_]), do: decode(iolist_to_binary(iolist))

  def decode(str) do
    try do
      decode_simple(str)
    catch
      :incomplete ->
        {:incomplete, str}
    end
  end

  def decode_simple(<<>>), do: throw(:incomplete)

  @doc false
  def decode_simple(str = <<first::size(8), _::binary>>)
  when ?0 <= first and first <= ?9 do
    Strings.decode(str)
  end

  @doc false
  def decode_simple(<<?i, rest::binary>>) do
    Integers.decode(rest, 0, :start)
  end

  @doc false
  def decode_simple(<<?l, rest::binary>>) do
    Lists.decode(rest, [])
  end

  @doc false
  def decode_simple(<<?d, rest::binary>>) do
    Dictionaries.decode(rest, HashDict.new(), "")
  end
end
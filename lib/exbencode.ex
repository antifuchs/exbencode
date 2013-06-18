defmodule Exbencode do
  def decode(str), do: Exbencode.Decoder.decode(str)
end

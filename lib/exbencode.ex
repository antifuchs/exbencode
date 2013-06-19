defmodule Exbencode do
  def decode(str), do: Exbencode.Decoder.decode(str)
  def encode(value), do: Exbencode.Encoder.encode(value)
end

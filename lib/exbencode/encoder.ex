defmodule Exbencode.Encoder do
  defp type_to_encode(value) when is_integer(value), do: :integer
  defp type_to_encode(value) when is_binary(value), do: :string
  defp type_to_encode(value) when is_list(value), do: :list
  defp type_to_encode(value) when is_record(value, HashDict), do: :dictionary

  def encode(value) do
    encode_as(value, type_to_encode(value))
  end

  def encode(value, type) do
    encode_as(value, type)
  end

  defp encode_as(i, :integer) do
    ["i#{i}e"]
  end

  defp encode_as(l, :string) do
    ["#{byte_size(l)}:", l]
  end

  defp encode_as(l, :list) do
    ["l", Enum.map(l, encode(&1)), "e"]
  end

  defp encode_as(d, :dictionary) do
    keys_and_values = Enum.map(Enum.sort(Dict.keys(d)), [encode(&1), encode(Dict.get(d, &1))])
    ["d", keys_and_values, "e"]
  end
end
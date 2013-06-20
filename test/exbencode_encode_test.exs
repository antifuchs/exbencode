Code.require_file "../test_helper.exs", __FILE__

defmodule ExbencodeEncoderTest do
  use ExUnit.Case

  defp encode(val) do
    to_binary(Exbencode.encode(val))
  end

  test "encodes integers" do
    assert "i200e" == encode(200)
  end

  test "encodes strings" do
    assert "4:foob" == encode("foob")
  end

  test "encodes lists" do
    assert "li200e2:abe" == encode([200, "ab"])
  end

  test "encodes dictionaries" do
    assert "d3:fooi200ee" = encode(HashDict.new([foo: 200]))
  end

  test "encodes nested structs" do
    assert "d3:food3:bari200eee" = encode(HashDict.new([foo: HashDict.new([bar: 200])]))
  end
end
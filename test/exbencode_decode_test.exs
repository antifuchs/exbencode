Code.require_file "../test_helper.exs", __FILE__

defmodule ExbencodeDecoderTest do
  use ExUnit.Case

  test "decodes one-element strings" do
    assert {"a", ""} = Exbencode.decode("1:a")
  end

  test "decodes zero-element strings" do
    assert {"", ""} = Exbencode.decode("0:")
  end

  test "decodes positive integers" do
    assert {10, ""} = Exbencode.decode("i10e")
  end

  test "decodes negative integers" do
    assert {-10, ""} = Exbencode.decode("i-10e")
  end

  test "decodes an empty list" do
    assert {[], ""} = Exbencode.decode("le")
  end

  test "decodes a list with elements" do
    assert {[10, "abc"], ""} = Exbencode.decode("li10e3:abce")
  end

  test "decodes a dictionary" do
    assert {[abc: 20, foo: "foo"], ""} =
      Exbencode.decode("d3:abci20e3:foo3:fooe")
  end

  test "decodes a dictionary containing a list as a value" do
    assert {[abc: [10]], ""} =
      Exbencode.decode("d3:abcli10eee")
  end

  test "decodes a dictionay containing a dictionary as a value" do
    assert {[abc: [foo: 10]], ""} =
      Exbencode.decode("d3:abcd3:fooi10eee")
  end
end

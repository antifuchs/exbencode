Code.require_file "../test_helper.exs", __FILE__

defmodule ExbencodeDecoderTest do
  use ExUnit.Case

  test "decodes iolists" do
    assert {"a", ""} = Exbencode.decode(["1", [":", "a"]])
  end

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

  test "refuses to decode integers with minus signs in the middle" do
    Enum.each ["i--1e", "i-1-1e", "i1-e"],
         fn(str) ->
             assert_raise FunctionClauseError, "no function clause matching in Exbencode.Decoder.Integers.decode/3",
             fn ->
                  Exbencode.decode(str)
             end
         end
  end

  test "decodes an empty list" do
    assert {[], ""} = Exbencode.decode("le")
  end

  test "decodes a list with elements" do
    assert {[10, "abc"], ""} = Exbencode.decode("li10e3:abce")
  end

  test "decodes a dictionary" do
    assert {dict, ""} =
      Exbencode.decode("d3:abci20e3:foo3:fooe")
    assert HashDict.equal?(HashDict.new([abc: 20, foo: "foo"]), dict)
  end

  test "decodes a dictionary containing a list as a value" do
    assert {dict, ""} =
      Exbencode.decode("d3:abcli10eee")
    assert HashDict.equal?(HashDict.new([abc: [10]]), dict)
  end

  test "decodes a dictionay containing a dictionary as a value" do
    assert {dict, ""} = Exbencode.decode("d3:abcd3:fooi10eee")
    assert HashDict.equal?(HashDict.new([abc: HashDict.new([foo: 10])]), dict)
  end

  test "detects an incomplete string" do
    assert {:incomplete, _} = Exbencode.decode("20:foo")
  end

  test "detects an incomplete int" do
    assert {:incomplete, _} = Exbencode.decode("i20000")
  end

  test "detects an incomplete list" do
    assert {:incomplete, _} = Exbencode.decode("li20e")
  end

  test "detects an incomplete dict" do
    assert {:incomplete, _} = Exbencode.decode("d3:foo")
    assert {:incomplete, _} = Exbencode.decode("d3:foo3:bar")
  end

  test "Returns the entire string as remainder on imcomplete data" do
    str = "d3:bar3:foo3:fooi20e"
    assert {:incomplete, str} == Exbencode.decode(str)
  end
end

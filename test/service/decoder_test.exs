defmodule DMCD.Service.DecoderTest do
  use ExUnit.Case, async: true

  alias DMCD.Service.Decoder

  doctest Decoder

  describe "decoder:" do
    test "decodes words correctly" do
      code = ".- .-.. .--. .... .-"

      assert Decoder.run(code) == "ALPHA"
    end

    test "parses spaces correctly" do
      code = ".. ....... -.-"

      assert Decoder.run(code) == "I K"
    end

    test "checks if a code is supported" do
      assert Decoder.supported?("..")
      refute Decoder.supported?(".-+")
    end

    test "returns accurate space code" do
      space_code = Decoder.space_code()

      assert Decoder.run(space_code) == " "
    end
  end
end

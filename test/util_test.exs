defmodule DMCD.UtilTest do
  use ExUnit.Case, async: true

  alias DMCD.Util

  doctest Util

  describe "util:" do
    test "encodes a map to string" do
      assert is_binary(Util.json_encode!(%{hello: "world!"}))
    end

    test "decodes a JSON string to map" do
      assert is_map(Util.json_decode!("{\"hello\": \"world!\"}"))
    end

    test "correctly fetches an application environment variable" do
      key = :test_env_param
      value = "Some random value"
      Application.put_env(:dmcd, key, value)

      assert Util.fetch_env!(key) == value
    end
  end
end

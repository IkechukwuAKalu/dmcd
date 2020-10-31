defmodule DMCD.Service.BurnerTest do
  use ExUnit.Case, async: true

  alias DMCD.Service.{Burner, Store}

  doctest Burner

  describe "burner:" do
    test "deletes a message from the store after a duration" do
      store = start_supervised!(Store)
      value = "Hello World"
      key = Store.create(store, nil, value)

      assert Store.lookup(store, key) == value

      # burn message after 1 second
      :ok = Burner.attach(store, key, 10)
      :timer.sleep(20)

      assert is_nil(Store.lookup(store, key))
    end
  end
end

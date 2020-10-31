defmodule DMCD.Service.StoreTest do
  use ExUnit.Case, async: true

  alias DMCD.Service.Store

  doctest Store

  describe "store:" do
    setup do
      store = start_supervised!(Store)

      %{store: store}
    end

    test "fetching values with keys succeeds", %{store: store} do
      value = "Ikechukwu"
      key = Store.create(store, nil, value)
      non_existent_key = "#{key}_#{key}"

      assert Store.lookup(store, key) == value
      assert is_nil(Store.lookup(store, non_existent_key))
    end

    test "storing values succeeds for new entries and returns the key", %{store: store} do
      assert is_integer(Store.create(store, nil, "Ikechukwu"))
    end

    test "specifying a custom key", %{store: store} do
      # Accepts custom key if it is an integer
      custom_key = 24
      assert Store.create(store, custom_key, "") == custom_key

      # Generates a new key if custom key is not an integer
      custom_key = "24"
      refute Store.create(store, custom_key, "") == custom_key
    end

    test "attached burner deletes a message after its time-to-live", %{store: store} do
      # Modify the env variables to make the message burn after 10ms
      ttl = "10"
      Application.put_env(:dmcd, :message_ttl, ttl)
      Application.put_env(:dmcd, :env, :dev)

      code = ".."
      key = Store.create(store, nil, code)
      assert code == Store.lookup(store, key)
      sleep_time = ttl |> String.to_integer() |> Kernel.*(2)
      :timer.sleep(sleep_time)
      assert is_nil(Store.lookup(store, key))

      # Reset app env back to test
      Application.put_env(:dmcd, :env, :test)
    end

    test "storing values generate sequential integer keys converted", %{store: store} do
      key_1 = Store.create(store, nil, "Ikechukwu")
      key_2 = Store.create(store, nil, "Kalu")
      key_3 = Store.create(store, nil, "LEO")

      assert key_2 > key_1 and key_3 > key_2
    end

    test "updating with an existing key succeeds", %{store: store} do
      value_1 = "Ikechukwu"
      value_2 = "LEO"
      key = Store.create(store, nil, value_1)

      assert :ok == Store.update(store, key, value_2)
      assert Store.lookup(store, key) == value_2
    end

    test "updating with a non-existent key fails", %{store: store} do
      assert :error == Store.update(store, "a random key", "AA")
    end

    test "deleting a key and value succeeds", %{store: store} do
      key = Store.create(store, nil, "LEO")

      Store.delete(store, key)
      assert is_nil(Store.lookup(store, key))
    end
  end
end

defmodule DMCD.Web.EndpointTest do
  @moduledoc """
  This test module covers both the web endpoint module and the endpoint handler module
  """

  use ExUnit.Case, async: true
  use Plug.Test

  alias DMCD.Web.Endpoint
  alias DMCD.Service.Store
  alias DMCD.Util

  @opts Endpoint.init([])

  describe "endpoint:" do
    test "generates a new id" do
      conn = conn(:post, "/new", %{})
      conn = Endpoint.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert %{"id" => id} = Util.json_decode!(conn.resp_body)
      assert String.to_integer(id) > 0
    end

    test "handles non_existent routes" do
      conn = conn(:get, "/hello_world")
      conn = Endpoint.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 404

      assert conn.resp_body ==
               "oops... you're not lost, we just haven't handled this route yet :-)"
    end
  end

  describe "endpoint decoder:" do
    setup do
      store = Store.store_process()
      key = Store.create(store, nil, "")

      %{key: key, store: store}
    end

    test "adding a code to a message with an existing key succeeds", %{key: key} do
      conn = conn(:put, "/decode/#{key}", Util.json_encode!(%{code: ".."}))
      conn = Endpoint.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == "OK"
    end

    test "adding a code to a message with a non-existent key fails", %{key: key} do
      invalid_key = "#{key}#{key}"
      conn = conn(:put, "/decode/#{invalid_key}", Util.json_encode!(%{code: ".."}))
      conn = Endpoint.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 404
      assert conn.resp_body == "MESSAGE_NOT_FOUND"
    end

    test "adding an unsupported code to a message fails", %{key: key} do
      conn = conn(:put, "/decode/#{key}", Util.json_encode!(%{code: ".-+"}))
      conn = Endpoint.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 400
      assert conn.resp_body == "CODE_NOT_SUPPORTED"
    end

    test "retrieving a message with an existing key succeeds", %{key: key} do
      make_request = fn code ->
        conn = conn(:put, "/decode/#{key}", Util.json_encode!(%{code: code}))
        Endpoint.call(conn, @opts)
      end

      ["..", " ", ".-", "--"]
      |> Enum.each(&make_request.(&1))

      conn = conn(:get, "/decode/#{key}")
      conn = Endpoint.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert %{"text" => "I AM"} = Util.json_decode!(conn.resp_body)
    end

    test "retrieving a message with a non-existent key fails", %{key: key} do
      invalid_key = "#{key}#{key}"
      conn = conn(:get, "/decode/#{invalid_key}")
      conn = Endpoint.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 404
      assert conn.resp_body == "MESSAGE_NOT_FOUND"
    end
  end
end

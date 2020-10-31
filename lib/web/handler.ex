defmodule DMCD.Web.Handler do
  @moduledoc """
  This module processes web requests and sends a response
  """

  alias DMCD.Service.{Store, Decoder}
  alias DMCD.Util
  alias Plug.Conn

  @store_process Store.store_process()

  @spec new(Conn.t()) :: Conn.t()
  def new(%Conn{} = conn) do
    key = @store_process |> Store.create(nil, "") |> to_string

    send_response(conn, 200, Util.json_encode!(%{id: key}))
  end

  @spec add_code(Conn.t()) :: Conn.t()
  def add_code(%Conn{path_params: %{"key" => key}} = conn) do
    {:ok, stringified_payload, _} = Conn.read_body(conn)
    %{"code" => code} = Util.json_decode!(stringified_payload)

    key = String.to_integer(key)

    with true <- Decoder.supported?(code) or code == " ",
         value when is_binary(value) <- Store.lookup(@store_process, key) do
      code = if code == " ", do: Decoder.space_code(), else: code

      new_value = String.trim(value <> " " <> code, " ")

      :ok = Store.update(@store_process, key, new_value)

      send_response(conn, 200, "OK")
    else
      nil -> send_response(conn, 404, "MESSAGE_NOT_FOUND")
      false -> send_response(conn, 400, "CODE_NOT_SUPPORTED")
    end
  end

  @spec decode(Conn.t()) :: Conn.t()
  def decode(%Conn{path_params: %{"key" => key}} = conn) do
    key = String.to_integer(key)

    case Store.lookup(@store_process, key) do
      nil ->
        send_response(conn, 404, "MESSAGE_NOT_FOUND")

      coded_message ->
        decoded_message = Decoder.run(coded_message)

        send_response(conn, 200, Util.json_encode!(%{text: decoded_message}))
    end
  end

  defp send_response(%Conn{} = conn, status_code, message) do
    conn
    |> Conn.put_resp_content_type("text/plain")
    |> Conn.send_resp(status_code, message)
  end
end

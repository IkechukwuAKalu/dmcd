defmodule DMCD.Web.Endpoint do
  @moduledoc """
  This module defines the plug middleware and endpoint routes
  """

  use Plug.Router

  alias DMCD.Util

  if Util.fetch_env!(:env) == :dev, do: use(Plug.Debugger)

  alias DMCD.Web.Handler

  if Util.fetch_env!(:env) == :dev, do: plug(Plug.Logger)

  plug(:match)
  plug(:dispatch)

  post("/new", do: Handler.new(conn))
  put("/decode/:key", do: Handler.add_code(conn))
  get("/decode/:key", do: Handler.decode(conn))

  match _ do
    send_resp(conn, 404, "oops... you're not lost, we just haven't handled this route yet :-)")
  end
end

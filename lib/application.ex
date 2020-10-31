defmodule DMCD.Application do
  use Application

  alias DMCD.Service.Store
  alias DMCD.Util

  @spec start([:supervisor.child_spec() | {module, term} | module], keyword) ::
          {:error, {:already_started, pid} | {:shutdown, term} | term} | {:ok, pid}
  def start(_type, _args) do
    port = :port |> Util.fetch_env!() |> String.to_integer()

    children = [
      Plug.Cowboy.child_spec(
        scheme: Util.fetch_env!(:scheme),
        plug: DMCD.Web.Endpoint,
        options: [port: port]
      ),
      {Store, [name: Store.store_process()]}
    ]

    opts = [strategy: :one_for_one, name: DMCD.Supervisor]

    Supervisor.start_link(children, opts)
  end
end

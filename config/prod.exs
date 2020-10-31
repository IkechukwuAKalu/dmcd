use Mix.Config

config :dmcd,
  env: :prod,
  scheme: :http,
  port: System.fetch_env!("DMCD_PORT")

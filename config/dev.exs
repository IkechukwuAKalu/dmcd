use Mix.Config

config :dmcd,
  env: :dev,
  scheme: :http,
  port: System.fetch_env!("DMCD_PORT")

use Mix.Config

config :dmcd,
  env: :test,
  scheme: :http,
  port: System.fetch_env!("DMCD_PORT"),
  allow_replication: false

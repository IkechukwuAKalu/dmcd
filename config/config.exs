use Mix.Config

config :dmcd,
  # Less than 5 minutes
  message_ttl: System.get_env("DMCD_MESSAGE_TTL") || "299000",
  allow_replication: true

import_config "#{Mix.env()}.exs"

defmodule DMCD.Util do
  @moduledoc """
  Utility module to provide helper functions and wrappers around libraries
  """
  require Logger

  @spec json_encode!(map) :: binary
  def json_encode!(map), do: Jason.encode!(map)

  @spec json_decode!(binary) :: map
  def json_decode!(stringified_json), do: Jason.decode!(stringified_json)

  @spec log_info(any) :: :ok
  def log_info(data) do
    if fetch_env!(:env) != :test, do: Logger.info(inspect(data))

    :ok
  end

  @spec fetch_env!(atom) :: binary
  def fetch_env!(key) do
    Application.fetch_env!(:dmcd, key)
  end
end

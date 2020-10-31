defmodule DMCD.Service.Burner do
  @moduledoc """
  Burner service that deletes messages after a duration in milliseconds
  """

  @spec attach(pid, integer, integer) :: :ok
  def attach(store, key, time_ms) do
    Process.sleep(time_ms)
    DMCD.Service.Store.delete(store, key)

    :ok
  end
end

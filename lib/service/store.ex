defmodule DMCD.Service.Store do
  @moduledoc """
  Store service for messages
  """
  use Agent

  alias DMCD.Util

  @id_state_key "__priv_last_id"

  @spec start_link(keyword) :: {:error, {:already_started, pid} | term} | {:ok, pid}
  def start_link(opts) do
    initial = Map.put(%{}, @id_state_key, 0)

    Agent.start_link(fn -> initial end, opts)
  end

  @spec store_process :: __MODULE__
  def store_process, do: __MODULE__

  @spec lookup(pid, integer) :: nil | binary
  def lookup(store, key), do: Agent.get(store, &Map.get(&1, key))

  @spec create(pid, binary | nil, binary, boolean) :: binary
  def create(store, key, value, replicate? \\ true) do
    key = if is_integer(key), do: key, else: generate_id(store)

    Agent.update(store, &Map.put_new(&1, key, value))

    if replicate?, do: create_replicate_data(store, key, value)

    attach_burner(store, key)

    key
  end

  @spec update(pid, integer, binary, boolean) :: :error | :ok
  def update(store, key, new_value, replicate? \\ true) do
    case lookup(store, key) do
      nil ->
        :error

      _ ->
        Agent.update(store, &Map.put(&1, key, new_value))
        if replicate?, do: update_replicate_data(store, key, new_value)

        :ok
    end
  end

  @spec delete(pid, integer) :: :ok
  def delete(store, key) do
    Agent.get_and_update(store, fn state -> Map.pop(state, key) end)

    :ok
  end

  defp generate_id(store) do
    new_id =
      store
      |> lookup(@id_state_key)
      |> Kernel.+(1)

    update(store, @id_state_key, new_id)

    new_id
  end

  # Creates an associated burner to delete the message after a duration
  defp attach_burner(store, key) do
    if Util.fetch_env!(:env) != :test do
      duration = :message_ttl |> Util.fetch_env!() |> String.to_integer()

      spawn(fn ->
        DMCD.Service.Burner.attach(store, key, duration)
      end)
    end
  end

  defp create_replicate_data(store, key, value) do
    replicate_data(:create, [store, key, value, false])
  end

  defp update_replicate_data(store, key, value) do
    replicate_data(:update, [store, key, value, false])
  end

  # Replicates data across other nodes on the cluster if any
  defp replicate_data(function, args) do
    if Util.fetch_env!(:allow_replication) do
      Enum.each(Node.list(), fn node ->
        Util.log_info(
          "Calling function #{function} with args=#{inspect(args)} to node #{inspect(node)}"
        )

        response = :rpc.call(node, __MODULE__, function, args)

        Util.log_info("Replication response is #{inspect(response)}")
      end)
    end
  end
end

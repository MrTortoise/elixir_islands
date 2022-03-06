defmodule IslandsEngine.GameSupervisor do
  use DynamicSupervisor

  alias IslandsEngine.Game

  @moduledoc """
  Responsible for starting, stopping and restarting named Game instances

  ## Examples
  iex> {:ok, game} = IslandsEngine.GameSupervisor.start_game("sup_test")
  iex> Process.alive?(game)
  true
  iex> IslandsEngine.GameSupervisor.stop_game("sup_test")
  iex> Process.alive?(game)
  false
  """

  def start_link(_options), do: DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl true
  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_game(name), do: DynamicSupervisor.start_child(__MODULE__, {Game, name})
  def stop_game(name), do: DynamicSupervisor.terminate_child(__MODULE__, name_to_pid(name))

  defp name_to_pid(name) do
    name
    |> Game.via_tuple()
    |> GenServer.whereis()
  end
end

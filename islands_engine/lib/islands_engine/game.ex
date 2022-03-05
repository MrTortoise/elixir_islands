defmodule IslandsEngine.Game do
  use GenServer

  alias IslandsEngine.{Board, Guesses, Rules}

  def start_link(name) when is_binary(name), do: GenServer.start_link(__MODULE__, name, [])

  @doc """
  Adds player 2 to the IslandsEngine.Game

  ## Example
  iex> alias IslandsEngine.Game
  iex> {:ok, game} = Game.start_link("Dave")
  iex> Game.add_player(game, "dave2")
  :ok
  iex> state = :sys.get_state(game)
  iex> state.player2.name == "dave2"
  true
  """
  def add_player(game, name) when is_binary(name), do: GenServer.call(game, {:add_player, name})

  def init(name) do
    player1 = %{name: name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
    {:ok, %{player1: player1, player2: player2, rules: Rules.new()}}
  end

  def handle_call({:add_player, name}, _from, state) do
    with {:ok, rules} <- Rules.check(state.rules, :add_player) do
      state
      |> update_player2_name(name)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state}
    end
  end

  defp update_player2_name(state, name), do: put_in(state.player2.name, name)
  defp update_rules(state, rules), do: %{state | rules: rules}
  defp reply_success(state, reply), do: {:reply, reply, state}
end

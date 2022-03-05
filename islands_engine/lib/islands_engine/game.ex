defmodule IslandsEngine.Game do
  use GenServer

  alias IslandsEngine.{Board, Guesses, Rules, Island, Coordinate}
  @players [:player1, :player2]

  def start_link(name) when is_binary(name), do: GenServer.start_link(__MODULE__, name, [])

  @doc """
  Adds player 2 to the IslandsEngine.Game

  ## Example
  iex> alias IslandsEngine.Game
  iex> {:ok, game} = Game.start_link("Dave")
  iex> Game.add_player(game, "dave2")
  :ok
  iex> :sys.get_state(game).player2.name == "dave2"
  true
  """
  def add_player(game, name) when is_binary(name), do: GenServer.call(game, {:add_player, name})

  @doc """
  allows players to position IslandsEngine.Island

  ## Example

  ### Happy PAth
  iex> alias IslandsEngine.Game
  iex> {:ok, game} = Game.start_link("Dave")
  iex> Game.add_player(game, "dave2")
  iex> Game.position_island(game, :player1, :square, 1, 1)
  :ok

  """
  def position_island(game, player, shape, row, col) when player in @players,
    do: GenServer.call(game, {:position_island, player, shape, row, col})

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

  def handle_call({:position_island, player, shape, row, col}, _from, state) do
    board = player_board(state, player)

    with {:ok, rules} <- Rules.check(state.rules, {:position_islands, player}),
         {:ok, coordinate} <- Coordinate.new(row, col),
         {:ok, island} <- Island.new(shape, coordinate),
         %{} = board <- Board.position_island(board, shape, island) do
      state
      |> update_board(player, board)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state}
      {:error, :invalid_coordinates} -> {:reply, {:error, :invalid_coordinates}, state}
      {:error, :invalid_island_type} -> {:reply, {:error, :invalid_island_type}, state}
      {:error, :overlapping_island} -> {:reply, {:error, :overlapping_island}, state}
    end
  end

  defp player_board(state, player), do: Map.get(state, player).board

  defp update_board(state, player, board),
    do: Map.update!(state, player, fn p -> %{p | board: board} end)
end

defmodule IslandsEngine.Game do
  use GenServer

  alias IslandsEngine.{Board, Guesses, Rules, Island, Coordinate}
  @players [:player1, :player2]
  @timeout 60 * 60 * 24 * 1000

  def via_tuple(name), do: {:via, Registry, {Registry.Game, name}}

  def start_link(name) when is_binary(name),
    do: GenServer.start_link(__MODULE__, name, name: via_tuple(name))

  def init(name) do
    player1 = %{name: name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
    {:ok, %{player1: player1, player2: player2, rules: Rules.new()}, @timeout}
  end

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

  iex> alias IslandsEngine.Game
  iex> {:ok, game} = Game.start_link("Dave")
  iex> Game.add_player(game, "dave2")
  iex> Game.position_island(game, :player1, :square, 1, 1)
  :ok

  """
  def position_island(game, player, shape, row, col) when player in @players,
    do: GenServer.call(game, {:position_island, player, shape, row, col})

  def set_islands(game, player) when player in @players,
    do: GenServer.call(game, {:set_islands, player})

  def guess_coordinate(game, player, row, col) when player in @players,
    do: GenServer.call(game, {:guess_coordinate, player, row, col})

  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end

  def handle_call({:add_player, name}, _from, state) do
    with {:ok, rules} <- Rules.check(state.rules, :add_player) do
      state
      |> update_player2_name(name)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> reply_error(state, :error)
    end
  end

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
      :error -> reply_error(state, :error)
      {:error, :invalid_coordinates} -> reply_error(state, {:error, :invalid_coordinates})
      {:error, :invalid_island_type} -> reply_error(state, {:error, :invalid_island_type})
      {:error, :overlapping_island} -> reply_error(state, {:error, :overlapping_island})
    end
  end

  def handle_call({:set_islands, player}, _from, state) do
    board = player_board(state, player)

    with {:ok, rules} <- Rules.check(state.rules, {:set_islands, player}),
         true <- Board.all_islands_positioned?(board) do
      state
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> reply_error(state, :error)
      false -> reply_error(state, {:error, :not_all_islands_positioned})
    end
  end

  def handle_call({:guess_coordinate, player, row, col}, _from, state) do
    opponent = opponent(player)
    opponent_board = player_board(state, opponent)

    with {:ok, rules} <- Rules.check(state.rules, {:guess_coordinate, player}),
         {:ok, coordinate} <- Coordinate.new(row, col),
         {hit_or_miss, forested_island, win_status, opponent_board} <-
           Board.guess(opponent_board, coordinate),
         {:ok, rules} <- Rules.check(rules, {:win_check, win_status}) do
      state
      |> update_board(opponent, opponent_board)
      |> update_guesses(player, hit_or_miss, coordinate)
      |> update_rules(rules)
      |> reply_success({hit_or_miss, forested_island, win_status})
    else
      :error -> reply_error(state, :error)
      {:error, :invalid_coordinates} -> reply_error(state, {:error, :invalid_coordinates})
    end
  end

  defp update_player2_name(state, name), do: put_in(state.player2.name, name)
  defp update_rules(state, rules), do: %{state | rules: rules}
  defp reply_success(state, reply), do: {:reply, reply, state, @timeout}
  defp reply_error(state, reply), do: {:reply, reply, state, @timeout}

  defp player_board(state, player), do: Map.get(state, player).board
  defp opponent(:player1), do: :player2
  defp opponent(:player2), do: :player1

  defp update_board(state, player, board),
    do: Map.update!(state, player, fn p -> %{p | board: board} end)

  defp update_guesses(state, player, hit_or_miss, coordinate) do
    update_in(state[player].guesses, fn guesses ->
      Guesses.add(guesses, hit_or_miss, coordinate)
    end)
  end
end

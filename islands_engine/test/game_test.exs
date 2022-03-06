defmodule GameTest do
  use ExUnit.Case, async: true
  doctest IslandsEngine.Game

  alias IslandsEngine.{Game}

  test "can add players to game" do
    {:ok, game} = Game.start_link("dave")
    :ok = Game.add_player(game, "fred")
    assert :sys.get_state(game).player2.name == "fred"
  end

  defp game_with_players_set(_context) do
    {:ok, game} = Game.start_link("dave")
    :ok = Game.add_player(game, "fred")
    %{game: game}
  end

  describe "Given a game with 2 players added" do
    setup [:game_with_players_set]

    test "player 1 add an island", context do
      game = context.game
      :ok = Game.position_island(game, :player1, :square, 1, 1)
      state = :sys.get_state(game)
      board = state.player1.board
      assert Map.has_key?(board, :square)
    end

    test "player 2 add an island", context do
      game = context.game
      :ok = Game.position_island(game, :player2, :square, 1, 1)
      state = :sys.get_state(game)
      board = state.player2.board
      assert Map.has_key?(board, :square)
    end

    test "when add invalid coordinate error", context do
      game = context.game
      {:error, :invalid_coordinates} = Game.position_island(game, :player1, :square, 1, 12)
    end

    test "when add invalid shape error", context do
      game = context.game
      {:error, :invalid_island_type} = Game.position_island(game, :player1, :dave, 1, 1)
    end

    test "attempt to set islands without positioning them all", context do
      game = context.game
      {:error, :not_all_islands_positioned} = Game.set_islands(game, :player1)
    end

    test "position all islands for player1 then set them", context do
      game = context.game
      Game.position_island(game, :player1, :square, 1, 1)
      Game.position_island(game, :player1, :s_shape, 2, 2)
      Game.position_island(game, :player1, :dot, 3, 1)
      Game.position_island(game, :player1, :atoll, 5, 1)
      Game.position_island(game, :player1, :l_shape, 8, 1)
      :ok = Game.set_islands(game, :player1)
    end

    test "position all islands for player2 then set them", context do
      game = context.game
      Game.position_island(game, :player2, :square, 1, 1)
      Game.position_island(game, :player2, :s_shape, 2, 2)
      Game.position_island(game, :player2, :dot, 3, 1)
      Game.position_island(game, :player2, :atoll, 5, 1)
      Game.position_island(game, :player2, :l_shape, 8, 1)
      :ok = Game.set_islands(game, :player2)
    end

    test "when islands set for both players game state is player 1 turn", context do
      game = context.game
      Game.position_island(game, :player1, :square, 1, 1)
      Game.position_island(game, :player1, :s_shape, 2, 2)
      Game.position_island(game, :player1, :dot, 3, 1)
      Game.position_island(game, :player1, :atoll, 5, 1)
      Game.position_island(game, :player1, :l_shape, 8, 1)
      Game.position_island(game, :player2, :square, 1, 1)
      Game.position_island(game, :player2, :s_shape, 2, 2)
      Game.position_island(game, :player2, :dot, 3, 1)
      Game.position_island(game, :player2, :atoll, 5, 1)
      Game.position_island(game, :player2, :l_shape, 8, 1)
      :ok = Game.set_islands(game, :player1)
      :ok = Game.set_islands(game, :player2)

      assert :sys.get_state(game).rules.state == :player1_turn
    end
  end

  defp game_with_all_islands_set(context) do
    game = context.game

    Game.position_island(game, :player1, :square, 1, 1)
    Game.position_island(game, :player1, :s_shape, 2, 2)
    Game.position_island(game, :player1, :dot, 3, 1)
    Game.position_island(game, :player1, :atoll, 5, 1)
    Game.position_island(game, :player1, :l_shape, 8, 1)
    :ok = Game.set_islands(game, :player1)

    Game.position_island(game, :player2, :square, 1, 1)
    Game.position_island(game, :player2, :s_shape, 2, 2)
    Game.position_island(game, :player2, :dot, 3, 1)
    Game.position_island(game, :player2, :atoll, 5, 1)
    Game.position_island(game, :player2, :l_shape, 8, 1)
    :ok = Game.set_islands(game, :player2)
  end

  describe "given islands are set" do
    setup [:game_with_players_set, :game_with_all_islands_set]

    test "get a hit when guessing a coord on an island", context do
      game = context.game
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 1, 1)
    end

    test "hit all of 1 island to get it returned :square as forested", context do
      game = context.game
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 1, 1)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 1, 1)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 1, 2)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 1, 2)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 2, 1)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 2, 1)
      {:hit, :square, :no_win} = Game.guess_coordinate(game, :player1, 2, 2)
    end

    test "hit all of all islands check game goes to state winner", context do
      game = context.game
      # square
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 1, 1)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 1, 1)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 1, 2)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 1, 2)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 2, 1)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 2, 1)
      {:hit, :square, :no_win} = Game.guess_coordinate(game, :player1, 2, 2)
      {:hit, :square, :no_win} = Game.guess_coordinate(game, :player2, 2, 2)

      # s_shape
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 2, 3)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 2, 3)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 3, 2)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 3, 2)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 3, 3)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 3, 3)
      {:hit, :s_shape, :no_win} = Game.guess_coordinate(game, :player1, 2, 4)
      {:hit, :s_shape, :no_win} = Game.guess_coordinate(game, :player2, 2, 4)

      # dot
      {:hit, :dot, :no_win} = Game.guess_coordinate(game, :player1, 3, 1)
      {:hit, :dot, :no_win} = Game.guess_coordinate(game, :player2, 3, 1)

      # Atoll
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 5, 1)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 5, 1)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 7, 1)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 7, 1)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 5, 2)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 5, 2)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 6, 2)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 6, 2)
      {:hit, :atoll, :no_win} = Game.guess_coordinate(game, :player1, 7, 2)
      {:hit, :atoll, :no_win} = Game.guess_coordinate(game, :player2, 7, 2)

      # L-shape
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 9, 1)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 9, 1)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 10, 1)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 10, 1)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player1, 8, 2)
      {:hit, :none, :no_win} = Game.guess_coordinate(game, :player2, 8, 2)

      {:hit, :l_shape, :win} = Game.guess_coordinate(game, :player1, 10, 2)
    end
  end
end

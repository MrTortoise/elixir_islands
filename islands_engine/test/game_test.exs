defmodule GameTest do
  use ExUnit.Case
  doctest IslandsEngine.Game

  alias IslandsEngine.{Game}

  test "can add players to game" do
    {:ok, game} = Game.start_link("dave")
    :ok = Game.add_player(game, "fred")
    assert :sys.get_state(game).player2.name == "fred"
  end

  defp game_with_players_set(context) do
    {:ok, game} = Game.start_link("dave")
    :ok = Game.add_player(game, "fred")
    %{game: game}
  end

  describe "Given a game with 2 players added" do
    setup [:game_with_players_set]

    test "add an island", context do
      game = context.game
      :ok = Game.position_island(game, :player1, :square, 1, 1)
      state = :sys.get_state(game)
      board = state.player1.board
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
  end
end

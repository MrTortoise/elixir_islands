defmodule IslandsEngine.Board do
  @moduledoc """
  Represents the board and manages the interactions of the parts.
  This is the aggregate root of the game and will likley form the base of main api.
  """

  alias IslandsEngine.{Island, Coordinate}

  @doc """
  ## Examples
  iex> IslandsEngine.Board.new()
  %{}
  """
  def new(), do: %{}

  @doc """
  If island can be placed it gets put onto the board otherwise returns {:error, _}

  ## Examples

  iex> board = IslandsEngine.Board.new()
  iex> {:ok, island} = IslandsEngine.Island.new(:square, %IslandsEngine.Coordinate{row: 1, col: 1})
  iex> IslandsEngine.Board.position_island(board, :square, island)
  %{
     square: %IslandsEngine.Island{
        coordinates: MapSet.new([
          %IslandsEngine.Coordinate{col: 1, row: 1},
          %IslandsEngine.Coordinate{col: 1, row: 2},
          %IslandsEngine.Coordinate{col: 2, row: 1},
          %IslandsEngine.Coordinate{col: 2, row: 2}]),
        hit_coordinates: %MapSet{}}
  }

  iex> board = IslandsEngine.Board.new()
  iex> {:ok, island} = IslandsEngine.Island.new(:square, %IslandsEngine.Coordinate{row: 1, col: 1})
  iex> board = IslandsEngine.Board.position_island(board, :square, island)
  iex> {:ok, island} = IslandsEngine.Island.new(:square, %IslandsEngine.Coordinate{row: 2, col: 2})
  iex> IslandsEngine.Board.position_island(board, :square, island)
  %{
     square: %IslandsEngine.Island{
        coordinates: MapSet.new([
          %IslandsEngine.Coordinate{col: 2, row: 2},
          %IslandsEngine.Coordinate{col: 2, row: 3},
          %IslandsEngine.Coordinate{col: 3, row: 2},
          %IslandsEngine.Coordinate{col: 3, row: 3}]),
        hit_coordinates: %MapSet{}}
  }

  iex> board = IslandsEngine.Board.new()
  iex> {:ok, island} = IslandsEngine.Island.new(:square, %IslandsEngine.Coordinate{row: 1, col: 1})
  iex> board = IslandsEngine.Board.position_island(board, :square, island)
  iex> {:ok, island} = IslandsEngine.Island.new(:s_shape, %IslandsEngine.Coordinate{row: 2, col: 2})
  iex> IslandsEngine.Board.position_island(board, :s_shape, island)
  %{
    s_shape: %IslandsEngine.Island{
      coordinates: MapSet.new([
        %IslandsEngine.Coordinate{col: 2, row: 3},
        %IslandsEngine.Coordinate{col: 3, row: 2},
        %IslandsEngine.Coordinate{col: 3, row: 3},
        %IslandsEngine.Coordinate{col: 4, row: 2}]),
      hit_coordinates: %MapSet{}
      },
    square: %IslandsEngine.Island{
      coordinates: MapSet.new([
        %IslandsEngine.Coordinate{col: 1, row: 1},
        %IslandsEngine.Coordinate{col: 1, row: 2},
        %IslandsEngine.Coordinate{col: 2, row: 1},
        %IslandsEngine.Coordinate{col: 2, row: 2}]),
      hit_coordinates: %MapSet{}
      }
    }

  iex> board = IslandsEngine.Board.new()
  iex> {:ok, island} = IslandsEngine.Island.new(:square, %IslandsEngine.Coordinate{row: 1, col: 1})
  iex> board = IslandsEngine.Board.position_island(board, :square, island)
  iex> {:ok, island} = IslandsEngine.Island.new(:s_shape, %IslandsEngine.Coordinate{row: 1, col: 1})
  iex> IslandsEngine.Board.position_island(board, :s_shape, island)
  {:error, :overlapping_island}
  """
  def position_island(board, key, %Island{} = island) do
    case overlaps_existing_island?(board, key, island) do
      true -> {:error, :overlapping_island}
      false -> Map.put(board, key, island)
    end
  end

  defp overlaps_existing_island?(board, new_key, new_island) do
    Enum.any?(board, fn {key, island} ->
      key != new_key and Island.overlaps?(island, new_island)
    end)
  end

  @doc """
  true when all islands are down

  ## Examples
  iex> IslandsEngine.Board.all_islands_positioned?(%{})
  false

  iex> board = IslandsEngine.Board.new()
  iex> {:ok, island} = IslandsEngine.Island.new(:square, %IslandsEngine.Coordinate{row: 1, col: 1})
  iex> board = IslandsEngine.Board.position_island(board, :square, island)
  iex> {:ok, island} = IslandsEngine.Island.new(:s_shape, %IslandsEngine.Coordinate{row: 2, col: 2})
  iex> board = IslandsEngine.Board.position_island(board, :s_shape, island)
  iex> {:ok, island} = IslandsEngine.Island.new(:dot, %IslandsEngine.Coordinate{row: 3, col: 1})
  iex> board = IslandsEngine.Board.position_island(board, :dot, island)
  iex> {:ok, island} = IslandsEngine.Island.new(:atoll, %IslandsEngine.Coordinate{row: 5, col: 1})
  iex> board = IslandsEngine.Board.position_island(board, :atoll, island)
  iex> {:ok, island} = IslandsEngine.Island.new(:l_shape, %IslandsEngine.Coordinate{row: 8, col: 1})
  iex> board = IslandsEngine.Board.position_island(board, :l_shape, island)
  iex> IslandsEngine.Board.all_islands_positioned?(board)
  true
  """
  def all_islands_positioned?(board), do: Enum.all?(Island.types(), &Map.has_key?(board, &1))

  @doc """
  takes a board and makes a guess but then returns an tuple with :hit / :miss, whether the hit thing has been forested or not, :win or :no_win and finally the IslandsEngine.Board

  ## Examples

    iex> IslandsEngine.Board.guess(%{}, %IslandsEngine.Coordinate{row: 1, col: 1})
    {:miss, :none, :no_win, %{}}

    iex> {:ok, island} = IslandsEngine.Island.new(:square, %IslandsEngine.Coordinate{row: 1, col: 1})
    iex> board = IslandsEngine.Board.position_island(%{}, :square, island)
    iex> IslandsEngine.Board.guess(board, %IslandsEngine.Coordinate{row: 1, col: 1})
    {
      :hit,
      :none,
      :no_win,
      %{
        square: %IslandsEngine.Island{
          coordinates: MapSet.new([
            %IslandsEngine.Coordinate{col: 1, row: 1},
            %IslandsEngine.Coordinate{col: 1, row: 2},
            %IslandsEngine.Coordinate{col: 2, row: 1},
            %IslandsEngine.Coordinate{col: 2, row: 2}]),
          hit_coordinates: MapSet.new([%IslandsEngine.Coordinate{col: 1, row: 1}])
        }
      }
    }

    iex> {:ok, island} = IslandsEngine.Island.new(:square, %IslandsEngine.Coordinate{row: 1, col: 1})
    iex> board = IslandsEngine.Board.position_island(%{}, :square, island)
    iex> {:hit, :none, :no_win, board} = IslandsEngine.Board.guess(board, %IslandsEngine.Coordinate{row: 1, col: 1})
    iex> {:hit, :none, :no_win, board} = IslandsEngine.Board.guess(board, %IslandsEngine.Coordinate{row: 1, col: 2})
    iex> {:hit, :none, :no_win, board} = IslandsEngine.Board.guess(board, %IslandsEngine.Coordinate{row: 2, col: 1})
    iex> IslandsEngine.Board.guess(board, %IslandsEngine.Coordinate{row: 2, col: 2})
    {
      :hit,
      :square,
      :win,
      %{
        square: %IslandsEngine.Island{
          coordinates: MapSet.new([
            %IslandsEngine.Coordinate{col: 1, row: 1},
            %IslandsEngine.Coordinate{col: 1, row: 2},
            %IslandsEngine.Coordinate{col: 2, row: 1},
            %IslandsEngine.Coordinate{col: 2, row: 2}]),
          hit_coordinates: MapSet.new([
            %IslandsEngine.Coordinate{col: 1, row: 1},
            %IslandsEngine.Coordinate{col: 1, row: 2},
            %IslandsEngine.Coordinate{col: 2, row: 1},
            %IslandsEngine.Coordinate{col: 2, row: 2}])
        }
      }
    }
  """
  def guess(board, %Coordinate{} = coordinate) do
    board
    |> check_all_islands(coordinate)
    |> guess_response(board)
  end

  defp check_all_islands(board, coordinate) do
    Enum.find_value(board, :miss, fn {key, island} ->
      case Island.guess(island, coordinate) do
        {:hit, island} -> {key, island}
        :miss -> false
      end
    end)
  end

  defp guess_response(:miss, board), do: {:miss, :none, :no_win, board}

  defp guess_response({key, island}, board) do
    board = %{board | key => island}
    {:hit, forest_check(board, key), win_check(board), board}
  end

  defp forest_check(board, key) do
    case forested?(board, key) do
      true -> key
      false -> :none
    end
  end

  defp forested?(board, key) do
    board
    # we know the coordinates hit so we know a key exists
    |> Map.fetch!(key)
    |> Island.forested?()
  end

  defp win_check(board) do
    case all_forested?(board) do
      true -> :win
      false -> :no_win
    end
  end

  defp all_forested?(board),
    do: Enum.all?(board, fn {_key, island} -> Island.forested?(island) end)
end

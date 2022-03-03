defmodule IslandsEngine.Board do
  @moduledoc """
  Represents the board and manages the interactions of the parts
  """

  alias IslandsEngine.Island

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
end

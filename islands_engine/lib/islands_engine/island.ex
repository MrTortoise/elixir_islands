defmodule IslandsEngine.Island do
  @moduledoc """
    Handles creation and overlap of islands
  """

  alias IslandsEngine.{Coordinate, Island}

  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct [:coordinates, :hit_coordinates]

  @doc """
  Creates a new shape of island at a position
  ##Examples

  iex> IslandsEngine.Island.new(:dave, %IslandsEngine.Coordinate{row: 1, col: 1})
  {:error, :invalid_island_type}

  iex> IslandsEngine.Island.new(:square, %IslandsEngine.Coordinate{row: 2, col: 10})
  {:error, :invalid_coordinates}

  iex> IslandsEngine.Island.new(:square, %IslandsEngine.Coordinate{row: 2, col: 2})
  {:ok,
    %IslandsEngine.Island{
     coordinates: MapSet.new([
       %IslandsEngine.Coordinate{col: 2, row: 2},
       %IslandsEngine.Coordinate{col: 2, row: 3},
       %IslandsEngine.Coordinate{col: 3, row: 2},
       %IslandsEngine.Coordinate{col: 3, row: 3}
     ]),
   hit_coordinates: %MapSet{}
  }}

  iex> IslandsEngine.Island.new(:atoll, %IslandsEngine.Coordinate{row: 2, col: 2})
  {:ok,
    %IslandsEngine.Island{
     coordinates: MapSet.new([
       %IslandsEngine.Coordinate{col: 2, row: 2},
       %IslandsEngine.Coordinate{col: 2, row: 4},
       %IslandsEngine.Coordinate{col: 3, row: 2},
       %IslandsEngine.Coordinate{col: 3, row: 3},
       %IslandsEngine.Coordinate{col: 3, row: 4}
     ]),
   hit_coordinates: %MapSet{}
  }}

  iex> IslandsEngine.Island.new(:dot, %IslandsEngine.Coordinate{row: 2, col: 2})
  {:ok,
    %IslandsEngine.Island{
     coordinates: MapSet.new([
       %IslandsEngine.Coordinate{col: 2, row: 2}
     ]),
   hit_coordinates: %MapSet{}
  }}

  iex> IslandsEngine.Island.new(:s_shape, %IslandsEngine.Coordinate{row: 2, col: 2})
  {:ok,
    %IslandsEngine.Island{
     coordinates: MapSet.new([
       %IslandsEngine.Coordinate{col: 2, row: 3},
       %IslandsEngine.Coordinate{col: 3, row: 2},
       %IslandsEngine.Coordinate{col: 3, row: 3},
       %IslandsEngine.Coordinate{col: 4, row: 2}
     ]),
   hit_coordinates: %MapSet{}
  }}

  iex> IslandsEngine.Island.new(:l_shape, %IslandsEngine.Coordinate{row: 2, col: 2})
  {:ok,
    %IslandsEngine.Island{
     coordinates: MapSet.new([
       %IslandsEngine.Coordinate{col: 2, row: 3},
       %IslandsEngine.Coordinate{col: 2, row: 4},
       %IslandsEngine.Coordinate{col: 3, row: 2},
       %IslandsEngine.Coordinate{col: 3, row: 4}
     ]),
   hit_coordinates: %MapSet{}
  }}
  """
  def new(type, %Coordinate{} = upper_left) do
    with [_ | _] = offsets <- offsets(type),
         %MapSet{} = coordinates <- add_coordinates(offsets, upper_left) do
      {:ok, %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  def add_coordinates(offsets, upper_left) do
    Enum.reduce_while(offsets, MapSet.new(), fn offset, acc ->
      add_coordinate(acc, upper_left, offset)
    end)
  end

  defp add_coordinate(coordinates, %Coordinate{row: row, col: col}, {row_offset, col_offset}) do
    case Coordinate.new(row + row_offset, col + col_offset) do
      {:ok, coordinate} ->
        {:cont, MapSet.put(coordinates, coordinate)}

      {:error, :invalid_coordinates} ->
        {:halt, {:error, :invalid_coordinates}}
    end
  end

  defp offsets(:square), do: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  defp offsets(:atoll), do: [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]
  defp offsets(:dot), do: [{0, 0}]
  defp offsets(:s_shape), do: [{0, 1}, {0, 2}, {1, 0}, {1, 1}]
  defp offsets(:l_shape), do: [{0, 1}, {1, 0}, {2, 0}, {2, 1}]
  defp offsets(_), do: {:error, :invalid_island_type}

  @doc """
  Detects overlapping islands

  ## Examples
  iex> {:ok, island1} = IslandsEngine.Island.new(:square, %IslandsEngine.Coordinate{row: 1,col: 1})
  iex> {:ok, island2} = IslandsEngine.Island.new(:atoll, %IslandsEngine.Coordinate{row: 4,col: 4})
  iex> IslandsEngine.Island.overlaps?(island1, island1)
  true
  iex> IslandsEngine.Island.overlaps?(island1, island2)
  false
  """
  def overlaps?(existing_island, new_island),
    do: not MapSet.disjoint?(existing_island.coordinates, new_island.coordinates)
end

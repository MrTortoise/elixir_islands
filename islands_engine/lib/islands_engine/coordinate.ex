defmodule IslandsEngine.Coordinate do
  @moduledoc """
  its a coordinate

  ## Examples
  iex> IslandsEngine.Coordinate.new(1,5)
  {:ok, %IslandsEngine.Coordinate{col: 5, row: 1}}

  iex> IslandsEngine.Coordinate.new(0,5)
  {:error, :invalid_coordinates}

  iex> IslandsEngine.Coordinate.new(11,5)
  {:error, :invalid_coordinates}

  iex> IslandsEngine.Coordinate.new(1,0)
  {:error, :invalid_coordinates}

  iex> IslandsEngine.Coordinate.new(6,11)
  {:error, :invalid_coordinates}


  """

  alias __MODULE__

  @enforce_keys [:row, :col]
  defstruct [:row, :col]

  @board_range 1..10
  def new(row, col) when row in(@board_range) and col in(@board_range), do:
    {:ok, %Coordinate{row: row, col: col}}

  def new(_row, _col), do: {:error, :invalid_coordinates}

end

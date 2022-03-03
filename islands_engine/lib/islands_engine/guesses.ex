defmodule IslandsEngine.Guesses do
  @moduledoc """
  Represents unique guesses

  ## Example

  #Can Add a hit to the guesses
  # Can add multiple hits into guesses
  # Cannot add the same hit multiple times

  iex> alias IslandsEngine.{Coordinate, Guesses}
  [IslandsEngine.Coordinate, IslandsEngine.Guesses]
  iex> guesses = Guesses.new
  %IslandsEngine.Guesses{hits: %MapSet{}, misses: %MapSet{}}
  iex> {:ok, coordinate1} = Coordinate.new(1,1)
  {:ok, %IslandsEngine.Coordinate{col: 1, row: 1}}
  iex> {:ok, coordinate2} = Coordinate.new(2,1)
  {:ok, %IslandsEngine.Coordinate{col: 1, row: 2}}
  iex> guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate1))
  %IslandsEngine.Guesses{
    hits: MapSet.new([%IslandsEngine.Coordinate{col: 1, row: 1}]),
    misses: %MapSet{}
  }
  iex> guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate2))
  %IslandsEngine.Guesses{
    hits: MapSet.new(
      [%IslandsEngine.Coordinate{col: 1, row: 1},
      %IslandsEngine.Coordinate{col: 1, row: 2}]
      ),
    misses: %MapSet{}
  }
  iex> _guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate2))
  %IslandsEngine.Guesses{
    hits: MapSet.new(
      [%IslandsEngine.Coordinate{col: 1, row: 1},
      %IslandsEngine.Coordinate{col: 1, row: 2}]
      ),
    misses: %MapSet{}
  }
"""

  alias __MODULE__

  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  @spec new :: %IslandsEngine.Guesses{hits: MapSet.t(any), misses: MapSet.t(any)}
  def new(), do:
    %Guesses{hits: MapSet.new, misses: MapSet.new}
end

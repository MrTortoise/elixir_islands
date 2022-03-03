defmodule IslandsEngine.Guesses do
  @moduledoc """
    Represents unique guesses

    ## Example

    # Can Add a hit to the guesses
    # Can add multiple hits into guesses
    # Cannot add the same hit multiple times

    iex> alias IslandsEngine.{Coordinate, Guesses}
    iex> {:ok, coordinate1} = Coordinate.new(1,1)
    iex> {:ok, coordinate2} = Coordinate.new(2,1)
    iex> guesses = Guesses.new
    %IslandsEngine.Guesses{hits: %MapSet{}, misses: %MapSet{}}
    iex> guesses = Guesses.add(guesses, :hit, coordinate1)
    %IslandsEngine.Guesses{
      hits: MapSet.new([%IslandsEngine.Coordinate{col: 1, row: 1}]),
      misses: %MapSet{}
    }
    iex> guesses = Guesses.add(guesses, :hit, coordinate2)
    %IslandsEngine.Guesses{
      hits: MapSet.new(
        [%IslandsEngine.Coordinate{col: 1, row: 1},
        %IslandsEngine.Coordinate{col: 1, row: 2}]
        ),
      misses: %MapSet{}
    }
    iex> guesses = Guesses.add(guesses, :hit, coordinate2)
    %IslandsEngine.Guesses{
      hits: MapSet.new(
        [%IslandsEngine.Coordinate{col: 1, row: 1},
        %IslandsEngine.Coordinate{col: 1, row: 2}]
        ),
      misses: %MapSet{}
    }
    iex> _guesses = Guesses.add(guesses, :miss, coordinate2)
    %IslandsEngine.Guesses{
      hits: MapSet.new(
        [%IslandsEngine.Coordinate{col: 1, row: 1},
        %IslandsEngine.Coordinate{col: 1, row: 2}]
        ),
      misses: MapSet.new(
        [%IslandsEngine.Coordinate{col: 1, row: 2}]
        ),
    }
  """

  alias IslandsEngine.{Coordinate, Guesses}

  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  def new(), do: %Guesses{hits: MapSet.new(), misses: MapSet.new()}

  def add(%Guesses{} = guesses, :hit, %Coordinate{} = coordinate),
    do: update_in(guesses.hits, &MapSet.put(&1, coordinate))

  def add(%Guesses{} = guesses, :miss, %Coordinate{} = coordinate),
    do: update_in(guesses.misses, &MapSet.put(&1, coordinate))
end

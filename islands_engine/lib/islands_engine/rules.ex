defmodule IslandsEngine.Rules do
  alias __MODULE__

  @moduledoc """
  This is the state machine for the game.
  Controls what commands players can execute at a given time.
  """

  defstruct state: :initialized,
            player1: :islands_not_set,
            player2: :islands_not_set

  @doc """
  creates rules stat as initialized

  ##Examples

  iex> IslandsEngine.Rules.new()
  %IslandsEngine.Rules{state: :initialized}
  """
  def new(), do: %Rules{}

  @doc """
  Given an existing state and a command will either return a new state or error

  :initialized + :add_player -> :players_set
  :players_set + {:position_islands, :player1} -> :players_set
  :players_set + {:position_islands, :player2} -> :players_set
  :players_set + {:set_islands, :player1} -> :players_set
  :players_set + {:set_islands, :player2} -> :players_set
  :players_set + {:set_islands, :player1} + {:set_islands :player2} -> :player1_turn
  :player1_turn + {:guess_coordinate, :player1} -> :player2_turn


  ##Examples
  ### Error Condition
  iex> IslandsEngine.Rules.check(:oops, :spoo)
  :error

  ### First action is add player
  iex> IslandsEngine.Rules.check(%IslandsEngine.Rules{}, :add_player)
  {:ok, %IslandsEngine.Rules{state: :players_set}}

  ### Random actions through error
  iex> IslandsEngine.Rules.check(%IslandsEngine.Rules{}, :random_thing)
  :error

  ### Given :players_set when {:position_islands :player1} then same state (:players_set)
  iex>rules = %IslandsEngine.Rules{state: :players_set}
  iex>IslandsEngine.Rules.check(rules, {:position_islands, :player1} )
  {:ok, %IslandsEngine.Rules{player1: :islands_not_set, player2: :islands_not_set, state: :players_set}}

  ### Given :players_set when {:position_islands :player2} then same state (:players_set)
  iex>rules = %IslandsEngine.Rules{state: :players_set}
  iex>IslandsEngine.Rules.check(rules, {:position_islands, :player2} )
  {:ok, %IslandsEngine.Rules{player1: :islands_not_set, player2: :islands_not_set, state: :players_set}}

  ### Given :players_set when {:set_islands :player1} then player1: :islands_set
  iex>rules = %IslandsEngine.Rules{state: :players_set}
  iex>IslandsEngine.Rules.check(rules, {:set_islands, :player1} )
  {:ok, %IslandsEngine.Rules{player1: :islands_set, player2: :islands_not_set, state: :players_set}}

  ### Given :players_set when {:set_islands :player1} then player1: :islands_set
  iex>rules = %IslandsEngine.Rules{state: :players_set}
  iex>IslandsEngine.Rules.check(rules, {:set_islands, :player2} )
  {:ok, %IslandsEngine.Rules{player1: :islands_not_set, player2: :islands_set, state: :players_set}}

  ## Given :players_set and :islands_set when {:position_islands, :player1} then error
  iex>rules = %IslandsEngine.Rules{state: :players_set, player1: :islands_set}
  iex>IslandsEngine.Rules.check(rules, {:position_islands, :player1} )
  :error

  ## Given :players_set and :islands_set when {:position_islands, :player2} then error
  iex>rules = %IslandsEngine.Rules{state: :players_set, player2: :islands_set}
  iex>IslandsEngine.Rules.check(rules, {:position_islands, :player2} )
  :error

  ## Given :players_set and :player2 :islands_set  when {:set_islands :player1} then :player1_turn
  iex>rules = %IslandsEngine.Rules{state: :players_set, player2: :islands_set}
  iex>IslandsEngine.Rules.check(rules, {:set_islands, :player1} )
  {:ok, %IslandsEngine.Rules{player1: :islands_set, player2: :islands_set, state: :player1_turn}}

  ## Given :players_set and :player1 :islands_set  when {:set_islands :player2} then :player1_turn
  iex>rules = %IslandsEngine.Rules{state: :players_set, player1: :islands_set}
  iex>IslandsEngine.Rules.check(rules, {:set_islands, :player2} )
  {:ok, %IslandsEngine.Rules{player1: :islands_set, player2: :islands_set, state: :player1_turn}}

  ## Given :player1_turn when {:guess_coordinate, :player1} then :player2_turn
  iex>rules = %IslandsEngine.Rules{state: :player1_turn}
  iex>IslandsEngine.Rules.check(rules, {:guess_coordinate, :player1} )
  {:ok, %IslandsEngine.Rules{state: :player2_turn}}

  ## Given :player1_turn when {:guess_coordinate, :player2} then :error
  iex>rules = %IslandsEngine.Rules{state: :player2_turn}
  iex>IslandsEngine.Rules.check(rules, {:guess_coordinate, :player1} )
  :error

  ## Given :player2_turn when {:guess_coordinate, :player2} then :player1_turn
  iex>rules = %IslandsEngine.Rules{state: :player2_turn}
  iex>IslandsEngine.Rules.check(rules, {:guess_coordinate, :player2} )
  {:ok, %IslandsEngine.Rules{state: :player1_turn}}

  ## Given :player2_turn when {:guess_coordinate, :player1} then :error
  iex>rules = %IslandsEngine.Rules{state: :player1_turn}
  iex>IslandsEngine.Rules.check(rules, {:guess_coordinate, :player2} )
  :error

  ## Given :player1_turn when {:win_check, :win} then :game_over
  iex>rules = %IslandsEngine.Rules{state: :player1_turn}
  iex>IslandsEngine.Rules.check(rules, {:win_check, :win} )
  {:ok, %IslandsEngine.Rules{state: :game_over}}

  ## Given :player1_turn when {:win_check, :win} then :player1_turn
  iex>rules = %IslandsEngine.Rules{state: :player1_turn}
  iex>IslandsEngine.Rules.check(rules, {:win_check, :no_win} )
  {:ok, %IslandsEngine.Rules{state: :player1_turn}}

  ## Given :player2_turn when {:win_check, :win} then :game_over
  iex>rules = %IslandsEngine.Rules{state: :player2_turn}
  iex>IslandsEngine.Rules.check(rules, {:win_check, :win} )
  {:ok, %IslandsEngine.Rules{state: :game_over}}

  ## Given :player2_turn when {:win_check, :win} then :player2_turn
  iex>rules = %IslandsEngine.Rules{state: :player2_turn}
  iex>IslandsEngine.Rules.check(rules, {:win_check, :no_win} )
  {:ok, %IslandsEngine.Rules{state: :player2_turn}}
  """

  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %Rules{rules | state: :players_set}}
  end

  def check(%Rules{state: :players_set} = rules, {:position_islands, player}) do
    case Map.fetch!(rules, player) do
      :islands_set -> :error
      :islands_not_set -> {:ok, rules}
    end
  end

  def check(%Rules{state: :players_set} = rules, {:set_islands, player}) do
    rules = Map.put(rules, player, :islands_set)

    case both_players_set_islands?(rules) do
      true -> {:ok, Map.put(rules, :state, :player1_turn)}
      false -> {:ok, rules}
    end
  end

  def check(%Rules{state: :player1_turn} = rules, {:guess_coordinate, :player1}),
    do: {:ok, %Rules{rules | state: :player2_turn}}

  def check(%Rules{state: :player1_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %Rules{rules | state: :game_over}}
    end
  end

  def check(%Rules{state: :player2_turn} = rules, {:guess_coordinate, :player2}),
    do: {:ok, %Rules{rules | state: :player1_turn}}

  def check(%Rules{state: :player2_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %Rules{rules | state: :game_over}}
    end
  end

  def check(_state, _action), do: :error

  defp both_players_set_islands?(rules),
    do: rules.player1 == :islands_set and rules.player2 == :islands_set
end

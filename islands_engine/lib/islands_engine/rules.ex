defmodule IslandsEngine.Rules do
  alias __MODULE__

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
  checks what state to return given an action

  :initialized + :add_player -> :players_set
  :players_set + {:position_islands :player1} + {:position_islands :player2} -> :player1_turn

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


  """
  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %Rules{rules | state: :players_set}}
  end

  # def check(%Rules{})

  def check(%Rules{state: :players_set} = rules, {:position_islands, player}) do
    {:ok, rules}
  end

  def check(_state, _action), do: :error
end
defmodule IslandsEngineTest do
  use ExUnit.Case, async: true
  doctest IslandsEngine

  test "greets the world" do
    assert IslandsEngine.hello() == :world
  end
end

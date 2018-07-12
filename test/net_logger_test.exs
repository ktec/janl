defmodule NetLoggerTest do
  use ExUnit.Case
  doctest NetLogger

  test "greets the world" do
    assert NetLogger.hello() == :world
  end
end

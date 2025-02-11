defmodule DidHandlerTest do
  use ExUnit.Case
  doctest DidHandler

  test "greets the world" do
    assert DidHandler.hello() == :world
  end
end

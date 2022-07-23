defmodule JsonToElixirTest do
  use ExUnit.Case
  doctest JsonToElixir

  test "greets the world" do
    assert JsonToElixir.hello() == :world
  end
end

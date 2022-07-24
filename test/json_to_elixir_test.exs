defmodule JsonToElixirTest do
  use ExUnit.Case
  doctest JsonToElixir

  @invalid_function_json File.read!("priv/test/invalid_function.json")

  describe "invalid function" do
    test "js" do
      assert {:error, :invalid_function} =
               JsonToElixir.Javascript.from_json(Erroring, @invalid_function_json)
    end

    test "elixir" do
      assert {:error, :invalid_function} =
               JsonToElixir.Elixir.from_json(Erroring, @invalid_function_json)
    end
  end
end

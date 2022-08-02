defmodule JsonToElixir.ElixirTest do
  use ExUnit.Case, async: true

  test "add" do
    data = %{
      "functions" => [
        %{
          "name" => "my_add",
          "arguments" => [
            %{
              "name" => "x",
              "type" => "any"
            },
            %{
              "name" => "y",
              "type" => "any"
            }
          ],
          "body" => [
            %{
              "out" => "z",
              "code" => %{
                "function" => "add",
                "args" => [%{"variable" => "x"}, %{"variable" => "y"}]
              }
            },
            %{
              "code" => %{
                "function" => "add",
                "args" => [%{"const" => 1}, %{"variable" => "z"}]
              }
            }
          ]
        }
      ]
    }

    {:ok, ast} = JsonToElixir.Ast.new(Testing, data)

    out = JsonToElixir.Elixir.ast_to_quoted(ast, [])

    assert {:defmodule, _, [Testing, _]} = out
    assert {{:module, module, _, {:my_add, _}}, _} = Code.eval_quoted(out)
    assert 15 == apply(module, :my_add, [5, 9])
  end
end

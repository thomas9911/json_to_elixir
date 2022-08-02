defmodule JsonToElixir.JavascriptTest do
  use ExUnit.Case, async: true

  defp ignore_formatting(js) do
    js |> String.split() |> Enum.join(" ")
  end

  defp node_apply(code) do
    {out, 0} = System.cmd("node", ["-e", code])

    String.trim(out)
  end

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

    out =
      ast
      |> JsonToElixir.Javascript.ast_to_code([])
      |> ignore_formatting()

    assert "const my_add = (x, y) => { let z = x + y; return 1 + z; }" == out

    assert "15" == node_apply(out <> "; console.log(my_add(5, 9))")
  end
end

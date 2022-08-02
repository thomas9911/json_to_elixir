defmodule JsonToElixir.ContextValidatorTest do
  use ExUnit.Case, async: true

  import Jason.Sigil

  alias JsonToElixir.ContextValidator

  @input ~j|
  {
    "functions": [
      {
        "name": "my_add",
        "arguments": [
          {
            "name": "x",
            "type": "any"
          },
          {
            "name": "y",
            "type": "any"
          }
        ],
        "body": [
          {
            "out": "z",
            "code": {
              "function": "add",
              "args": [{ "variable": "x" }, { "variable": "y" }]
            }
          },
          {
            "out": null,
            "code": {
              "function": "add",
              "args": [{ "variable": "z" }, { "variable": "y" }]
            }
          }
        ]
      }
    ]
  } |

  test "works" do
    {:ok, ast} = JsonToElixir.Ast.new(ValidationTest, @input)
    assert :ok == ContextValidator.validate(ast)
  end

  test "invalid variable" do
    input =
      put_in(
        @input,
        [
          "functions",
          Access.at!(0),
          "body",
          Access.at!(1),
          "code",
          "args",
          Access.at!(0),
          "variable"
        ],
        "invalid_var"
      )

    {:ok, ast} = JsonToElixir.Ast.new(ValidationTest, input)
    assert {:error, {:invalid_variable, "invalid_var"}} == ContextValidator.validate(ast)
  end
end

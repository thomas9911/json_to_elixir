defmodule JsonToElixir.AstTest do
  use ExUnit.Case, async: true

  import Jason.Sigil

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
            "out": null,
            "code": {
              "function": "add",
              "args": [{ "variable": "x" }, { "variable": "y" }]
            }
          }
        ]
      }
    ]
  } |

  test "invalid type" do
    input =
      put_in(
        @input,
        ["functions", Access.at!(0), "arguments", Access.at!(0), "type"],
        "not a type"
      )

    assert {:error, error} = JsonToElixir.Ast.new(LoaderTest, input)

    assert %{
             functions: [
               %{
                 arguments: [
                   %{
                     type: ["type is invalid: 'not a type' is not in ['any', 'string', 'number']"]
                   },
                   %{}
                 ]
               }
             ]
           } ==
             PolymorphicEmbed.traverse_errors(error, fn changeset, field, {message, opts} ->
               value = changeset.changes[field]
               allowed = "['#{Enum.join(opts[:enum], "', '")}']"

               "#{field} #{message}: '#{value}' is not in #{allowed}"
             end)
  end
end

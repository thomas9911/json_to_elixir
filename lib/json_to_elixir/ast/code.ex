defmodule JsonToElixir.Ast.Code do
  use Ecto.Schema
  use JsonToElixir.Ast

  @primary_key false
  embedded_schema do
    field(:function, :string)

    field(:args, {:array, PolymorphicEmbed},
      types: [
        variable: [module: JsonToElixir.Ast.Argument.Variable, identify_by_fields: [:variable]],
        const: [module: JsonToElixir.Ast.Argument.Const, identify_by_fields: [:const]],
        code: [module: JsonToElixir.Ast.Code, identify_by_fields: [:function]]
      ],
      on_replace: :delete
    )
  end
end

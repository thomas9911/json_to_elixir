defmodule JsonToElixir.Ast.InputArgument do
  use Ecto.Schema
  use JsonToElixir.Ast

  @primary_key false
  embedded_schema do
    field(:name, :string)
    field(:type, :string)
  end
end

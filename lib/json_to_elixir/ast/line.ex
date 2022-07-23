defmodule JsonToElixir.Ast.Line do
  use Ecto.Schema
  use JsonToElixir.Ast, not_required: [:out]
  alias JsonToElixir.Ast.Code


  @primary_key false
  embedded_schema do
    field(:out, :string)
    embeds_one(:code, Code)
  end
end

defmodule JsonToElixir.Ast.Root do
  use Ecto.Schema
  use JsonToElixir.Ast

  alias JsonToElixir.Ast.Function

  @primary_key false
  embedded_schema do
    embeds_many(:functions, Function)
  end
end

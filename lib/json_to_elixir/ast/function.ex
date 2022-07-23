defmodule JsonToElixir.Ast.Function do
  use Ecto.Schema
  use JsonToElixir.Ast

  alias JsonToElixir.Ast.InputArgument
  alias JsonToElixir.Ast.Line

  @primary_key false
  embedded_schema do
    field :name, :string
    embeds_many(:arguments, InputArgument)
    embeds_many(:body, Line)
  end
end

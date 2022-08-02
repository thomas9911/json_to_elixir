defmodule JsonToElixir.Ast.InputArgument do
  use Ecto.Schema
  use JsonToElixir.Ast

  alias Ecto.Changeset

  @valid_types [
    "any",
    "string",
    "number"
  ]

  @primary_key false
  embedded_schema do
    field(:name, :string)
    field(:type, :string)
  end

  def load(changeset \\ __MODULE__.__struct__(), params) do
    changeset
    |> super(params)
    |> Changeset.validate_inclusion(:type, @valid_types)
  end
end

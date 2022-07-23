defmodule JsonToElixir.Ast.Argument do
  defmodule Variable do
    use Ecto.Schema
    use JsonToElixir.Ast

    @primary_key false
    embedded_schema do
      field(:variable, :string)
    end
  end

  defmodule Const do
    use Ecto.Schema
    use JsonToElixir.Ast

    @primary_key false
    embedded_schema do
      field(:const, EctoTypeAny)
    end
  end
end

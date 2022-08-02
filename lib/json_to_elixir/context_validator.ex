defmodule JsonToElixir.ContextValidator do
  @moduledoc """
  Checks if the Ast is correct / makes sense
  """
  defstruct variables: []

  @spec validate(JsonToElixir.Ast.t()) :: :ok | {:error, tuple}
  def validate(%JsonToElixir.Ast{} = ast) do
    ast
    |> do_validate(%__MODULE__{})
    |> as_result()
  end

  defp do_validate(%JsonToElixir.Ast{root: root}, context) do
    do_validate(root, context)
  end

  defp do_validate(%JsonToElixir.Ast.Root{functions: functions}, context) do
    loop_over(functions, context)
  end

  defp do_validate(%JsonToElixir.Ast.Function{arguments: arguments, body: body}, context) do
    input_vars = Enum.map(arguments, & &1.name)
    # overwrite previous variables
    context = %{context | variables: input_vars}

    loop_over(body, context)
  end

  defp do_validate(
         %JsonToElixir.Ast.Line{code: code, out: out_var},
         %{variables: variables} = context
       ) do
    case do_validate(code, context) do
      {:ok, context} when is_nil(out_var) ->
        {:ok, context}

      {:ok, context} ->
        {:ok, %{context | variables: [out_var | variables]}}

      error ->
        error
    end
  end

  defp do_validate(%JsonToElixir.Ast.Code{args: args}, context) do
    loop_over(args, context)
  end

  defp do_validate(
         %JsonToElixir.Ast.Argument.Variable{variable: variable},
         %{variables: variables} = context
       ) do
    if variable in variables do
      {:ok, context}
    else
      {:error, {:invalid_variable, variable}}
    end
  end

  defp do_validate(%JsonToElixir.Ast.Argument.Const{}, context) do
    {:ok, context}
  end

  defp loop_over(entities, context) when is_list(entities) do
    Enum.reduce_while(entities, {:ok, context}, fn item, {:ok, ctx} ->
      case do_validate(item, ctx) do
        {:ok, ctx} -> {:cont, {:ok, ctx}}
        error -> {:halt, error}
      end
    end)
  end

  defp as_result({:ok, _}), do: :ok
  defp as_result(error), do: error
end

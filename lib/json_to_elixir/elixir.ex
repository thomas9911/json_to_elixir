defmodule JsonToElixir.Elixir do
  @moduledoc """
  Documentation for `JsonToElixir.Elixir`.
  """

  def ast_to_quoted(%JsonToElixir.Ast{name: name, root: root}, opts) do
    functions = Enum.map(root.functions, &ast_to_quoted(&1, opts))

    quote do
      defmodule unquote(Macro.expand(name, __ENV__)) do
        (unquote_splicing(functions))
      end
    end
  end

  def ast_to_quoted(
        %JsonToElixir.Ast.Function{name: name, arguments: arguments, body: body},
        opts
      ) do
    block = Enum.map(body, &ast_to_quoted(&1, opts))
    func_arguments = Enum.map(arguments, &ast_to_quoted(&1, opts))

    quote do
      def unquote(String.to_atom(name))(unquote_splicing(func_arguments)) do
        (unquote_splicing(block))
      end
    end
  end

  def ast_to_quoted(%JsonToElixir.Ast.InputArgument{name: name, type: _}, _) do
    Macro.var(String.to_atom(name), __MODULE__)
  end

  def ast_to_quoted(
        %JsonToElixir.Ast.Line{
          out: nil,
          code: %JsonToElixir.Ast.Code{function: function, args: args}
        },
        opts
      ) do
    mapped_arguments = Enum.map(args, &ast_to_quoted(&1, opts))
    args_amount = Enum.count(args)

    case {ast_to_function(function, args_amount, opts), args_amount} do
      {{function, :infix}, 2} ->
        {function, [], mapped_arguments}

      {{function, :prefix}, _} ->
        {function, [], mapped_arguments}

      {{function, :wrapped_prefix}, _} ->
        {function, [], [mapped_arguments]}

      _ ->
        raise UndefinedFunctionError, "Invalid function"
    end
  end

  def ast_to_quoted(%JsonToElixir.Ast.Argument.Variable{variable: variable}, _) do
    Macro.var(String.to_atom(variable), __MODULE__)
  end

  def ast_to_quoted(%JsonToElixir.Ast.Argument.Const{const: const}, _) do
    const
  end

  def ast_to_quoted(%JsonToElixir.Ast.Line{out: out} = line, opts) do
    out_var = Macro.var(String.to_atom(out), __MODULE__)
    rest = ast_to_quoted(%{line | out: nil}, opts)

    quote do
      unquote(out_var) = unquote(rest)
    end
  end

  defp ast_to_function("add", 2, _) do
    {:+, :infix}
  end

  defp ast_to_function("concat", 2, _) do
    {:<>, :infix}
  end

  defp ast_to_function("concat", _, _) do
    {quote do
       Enum.join()
     end
     |> elem(0), :wrapped_prefix}
  end

  defp ast_to_function("trim", i, _) when i in [1, 2] do
    {quote do
       String.trim()
     end
     |> elem(0), :prefix}
  end

  defp ast_to_function(_, _, _) do
    nil
  end

  def from_json(name, txt) do
    case JsonToElixir.Ast.from_json(name, txt) do
      {:ok, ast} -> {:ok, ast_to_quoted(ast, [])}
      e -> e
    end
  rescue
    UndefinedFunctionError ->
      {:error, :invalid_function}
  end
end

defmodule JsonToElixir do
  @moduledoc """
  Documentation for `JsonToElixir`.
  """

  def ast_to_quoted(%JsonToElixir.Ast{name: name, root: root}, opts) do
    functions = Enum.map(root.functions, &ast_to_quoted(&1, opts))
    quote do
      defmodule unquote(Macro.expand(name, __ENV__)) do
        unquote_splicing(functions)
      end
    end
  end

  def ast_to_quoted(%JsonToElixir.Ast.Function{name: name, arguments: arguments, body: body}, opts) do
    block = Enum.map(body, &ast_to_quoted(&1, opts))
    func_arguments = Enum.map(arguments, &ast_to_quoted(&1, opts))

    quote do
      def unquote(String.to_atom(name))(unquote_splicing(func_arguments)) do
        unquote_splicing(block)
      end
    end
  end

  def ast_to_quoted(%JsonToElixir.Ast.InputArgument{name: name, type: _}, _) do
    Macro.var(String.to_atom(name), __MODULE__)
  end

  def ast_to_quoted(%JsonToElixir.Ast.Line{out: nil, code: %JsonToElixir.Ast.Code{function: function, args: args}}, opts) do
    mapped_arguments = Enum.map(args, &ast_to_quoted(&1, opts))
    case {ast_to_function(function, opts), Enum.count(args)} do
      {{function, :infix}, 2} ->
        {function, [], mapped_arguments}

      _ -> raise UndefinedFunctionError, "Invalid function"
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

  defp ast_to_function("add", _) do
    {:+, :infix}
  end

  def from_json(name, txt) do
    case JsonToElixir.Ast.from_json(name, txt) do
      {:ok, ast} -> {:ok, ast_to_quoted(ast, [])}
      e -> e
    end
  end
end

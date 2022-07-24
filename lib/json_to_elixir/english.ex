defmodule JsonToElixir.English do
  def ast_to_code(%JsonToElixir.Ast{name: _, root: root}, opts) do
    functions = Enum.map(root.functions, &ast_to_code(&1, opts))

    Enum.join(functions, "\n\n")
  end

  def ast_to_code(
        %JsonToElixir.Ast.Function{name: name, arguments: arguments, body: body},
        opts
      ) do
    block = Enum.map(body, &ast_to_code(&1, opts))
    func_arguments = Enum.map(arguments, &ast_to_code(&1, opts))

    {code_block, last} =
      case Enum.split(block, -1) do
        {[], [last]} ->
          {"", last}

        {inner_block, [last]} ->
          {Enum.join(inner_block, "\n"), last}

        _ ->
          {"", ""}
      end

    """
    function #{name} with inputs #{Enum.join(func_arguments, " and ")}:
      #{code_block}
      return #{last}
    """
  end

  def ast_to_code(%JsonToElixir.Ast.InputArgument{name: name, type: _}, _) do
    name
  end

  def ast_to_code(
        %JsonToElixir.Ast.Line{
          out: nil,
          code: %JsonToElixir.Ast.Code{function: function, args: args}
        },
        opts
      ) do
    mapped_arguments = Enum.map(args, &ast_to_code(&1, opts))
    amount_of_args = Enum.count(args)

    case {ast_to_function(function, amount_of_args, opts), amount_of_args} do
      {{function, :infix}, 2} ->
        "#{Enum.at(mapped_arguments, 0)} #{function} #{Enum.at(mapped_arguments, 1)}"

      {{function, :infix}, amount} when amount > 2 ->
        [first | rest] = mapped_arguments
        "#{first} #{function} #{Enum.join(rest, " and ")}"

      {{function, :prefix}, 1} ->
        [input] = mapped_arguments
        "#{function} #{input}"

      _ ->
        raise UndefinedFunctionError, "Invalid function"
    end
  end

  def ast_to_code(%JsonToElixir.Ast.Line{out: out} = line, opts) do
    out_var = out
    rest = ast_to_code(%{line | out: nil}, opts)

    "set #{out_var} equal to #{rest}"
  end

  def ast_to_code(%JsonToElixir.Ast.Argument.Variable{variable: variable}, _) do
    variable
  end

  def ast_to_code(%JsonToElixir.Ast.Argument.Const{const: const}, _) when is_binary(const) do
    ~s|'#{const}'|
  end

  def ast_to_code(%JsonToElixir.Ast.Argument.Const{const: const}, _) do
    const
  end

  defp ast_to_function("add", _, _) do
    {"add", :infix}
  end

  defp ast_to_function("concat", _, _) do
    {"combine", :infix}
  end

  defp ast_to_function("trim", 1, _) do
    {"trim away from", :prefix}
  end

  defp ast_to_function("trim", 2, _) do
    {"trim with", :infix}
  end

  defp ast_to_function(_, _, _) do
    nil
  end

  def from_json(name, txt) do
    case JsonToElixir.Ast.from_json(name, txt) do
      {:ok, ast} -> {:ok, ast_to_code(ast, [])}
      e -> e
    end
  rescue
    UndefinedFunctionError ->
      {:error, :invalid_function}
  end
end

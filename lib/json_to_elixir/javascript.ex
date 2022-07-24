defmodule JsonToElixir.Javascript do
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
          {Enum.join(inner_block, ";\n") <> ";", last}

        _ ->
          {"", ""}
      end

    """
      const #{name} = (#{Enum.join(func_arguments, ", ")}) => {
        #{code_block}
        return #{last};
      }
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

      {{function, :prefix}, _} ->
        "#{function}(#{Enum.join(mapped_arguments, ", ")})"

      {{[_ | _] = function, :postfix}, 2} ->
        [first_arg, second_arg] = mapped_arguments
        "#{first_arg}.#{Enum.join(function, second_arg)}"

      {{function, :postfix}, amount} when amount > 0 ->
        {[first_arg], rest} = Enum.split(mapped_arguments, 1)
        "#{first_arg}.#{function}(#{Enum.join(rest, ",")})"

      _ ->
        raise UndefinedFunctionError, "Invalid function"
    end
  end

  def ast_to_code(%JsonToElixir.Ast.Line{out: out} = line, opts) do
    out_var = out
    rest = ast_to_code(%{line | out: nil}, opts)

    "let #{out_var} = #{rest}"
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
    {"+", :infix}
  end

  defp ast_to_function("concat", _, _) do
    {"''.concat", :prefix}
  end

  defp ast_to_function("trim", 1, _) do
    {"trim", :postfix}
  end

  defp ast_to_function("trim", 2, _) do
    {["replace(RegExp(`^${", "}+`), '').replace(RegExp(`${", "}+$`), '')"], :postfix}
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

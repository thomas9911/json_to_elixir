data =  File.read!("stuff.json")

# {:ok, ast} = JsonToElixir.Ast.from_json(Fancy, data) |> IO.inspect()


{:ok, elixir} = JsonToElixir.from_json(Fancy, data)

# IO.inspect(elixir)
IO.puts(Macro.to_string(elixir) |> Code.format_string!())

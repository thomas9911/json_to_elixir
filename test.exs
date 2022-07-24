data =  File.read!("priv/test/fancy.json")

# {:ok, ast} = JsonToElixir.Ast.from_json(Fancy, data) |> IO.inspect()


{:ok, elixir} = JsonToElixir.Elixir.from_json(Fancy, data)

# IO.inspect(elixir)
# IO.puts(Macro.to_string(elixir) |> Code.format_string!())

elixir = elixir |> Macro.to_string() |> Code.format_string!()

File.write("lib/fancy.ex", elixir)


{:ok, javascript} = JsonToElixir.Javascript.from_json(Fancy, data)

# IO.inspect(javascript)
# IO.puts(javascript)

File.write("fancy.js", javascript)

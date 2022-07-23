defmodule JsonToElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :json_to_elixir,
      version: "0.1.0",
      elixir: "~> 1.14-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_edit, "~> 0.1.0", only: :dev},
      {:ecto, "~> 3.8.4"},
      {:jason, "~> 1.3.0"},
      {:polymorphic_embed, "~> 2.0.0"}
    ]
  end
end

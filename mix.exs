defmodule DMCD.MixProject do
  use Mix.Project

  def project do
    [
      app: :dmcd,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DMCD.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.8.0"},
      {:plug_cowboy, "~> 2.4.0"},
      {:jason, "~> 1.2.2"}
    ]
  end
end

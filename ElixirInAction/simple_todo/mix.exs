defmodule SimpleTodo.MixProject do
  use Mix.Project

  def project do
    [
      app: :todo,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      preferred_cli_env: [release: :prod]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {Todo.Application, []},
      applications: [:wobserver_ng],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.3.0", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:poolboy, "~> 1.5.2"},
      {:cowboy, "~> 2.9"},
      {:plug, "~> 1.14.2"},
      {:plug_cowboy, "~> 2.6.1"},
      {:distillery, "~> 2.1.1"},
      {:wobserver_ng, "~> 1.14"},
      {:rexbug, "~> 2.0.0-rc1"}
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp dialyzer() do
    [
      flags: [:missing_return, :extra_return, :unmatched_returns, :error_handling],
      ignore_warnings: "dialyzer.ignore"
    ]
  end
end

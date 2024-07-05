defmodule LambdaEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :lambda_ex,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [release: :prod, compile: :prod, test: :test],
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
      {:credo, ">= 0.0.0", only: [:dev], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false},
      {:assert_value, "~> 0.10.4", only: [:test, :dev]},

      # RUNTIME TYPE CHECKING
      # https://hexdocs.pm/type_check/readme.html
      {:type_check, "~> 0.13.5"},
      # for type checking streams
      {:stream_data, "~> 0.5.0"},

      # Benchmarking
      {:benchee, "~> 1.1", runtime: false, only: :bench}
    ]
  end
end

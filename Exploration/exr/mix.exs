defmodule Exr.MixProject do
  use Mix.Project

  def project do
    [
      app: :exr,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      preferred_cli_env: [release: :prod, test: :test],
      aliases: [test: "test --no-start"],
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Checking
      {:ex_check, "~> 0.16.0", only: [:dev], runtime: false},
      {:credo, ">= 0.0.0", only: [:dev], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false},
      {:doctor, ">= 0.0.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false},
      {:gettext, ">= 0.0.0", only: [:dev], runtime: false},
      {:sobelow, ">= 0.0.0", only: [:dev], runtime: false},
      {:mix_audit, ">= 0.0.0", only: [:dev], runtime: false},

      # RUNTIME TYPE CHECKING
      # https://hexdocs.pm/type_check/readme.html
      {:type_check, "~> 0.13.5"},
      # for type checking streams
      {:stream_data, "~> 0.5.0"},

      # Benchmarking
      {:benchee, "~> 1.1", runtime: false, only: [:dev, :test]},
      {:benchee_html, "~> 1.0", runtime: false, only: [:dev, :test]},

      # CLI monitoring
      {:observer_cli, "~> 1.7", only: :dev}
    ]
  end

  defp dialyzer() do
    [
      flags: [
        :missing_return,
        :extra_return,
        :unmatched_returns,
        :error_handling,
        :no_improper_lists
      ],
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end
end

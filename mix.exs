defmodule NetLogger.MixProject do
  use Mix.Project

  def project do
    [
      app: :net_logger,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ssl, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1"},
      {:esqlite, github: "connorRigby/esqlite", optional: true},
      {:uuid, "~> 1.1"}
    ]
  end
end

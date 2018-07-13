defmodule NetLogger.MixProject do
  use Mix.Project

  def project do
    [
      app: :net_logger,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/connorrigby/janl",
      homepage_url: "https://github.com/connorrigby/janl",
      description: description(),
      package: package(),
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
      # only used for server.
      {:esqlite, github: "connorRigby/esqlite", optional: true, only: :dev},
      {:jason, "~> 1.1"},
      {:uuid, "~> 1.1"},
      {:ex_doc, "~> 0.18.3", only: :dev},
      {:dialyxir, github: "jeremyjh/dialyxir", only: :dev}
    ]
  end

  defp description,
    do: """
    Just another Network Logger
    """

  defp package,
    do: [
      licenses: ["MIT"],
      maintainers: ["Connor Rigby"],
      links: %{"GitHub" => "https://github.com/connorrigby/janl"}
    ]
end

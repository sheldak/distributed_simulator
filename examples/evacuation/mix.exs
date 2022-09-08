defmodule Evacuation.MixProject do
  use Mix.Project

  def project do
    [
      app: :evacuation,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:exla, "~> 0.1.0-dev", github: "elixir-nx/nx", sparse: "exla", tag: "v0.1.0"},
      {:nx, "~> 0.1.0-dev", github: "elixir-nx/nx", sparse: "nx", tag: "v0.1.0", override: true},
      {:complex, "~> 0.3.0"},
      {:distributed_simulator, path: "../.."}
    ]
  end
end

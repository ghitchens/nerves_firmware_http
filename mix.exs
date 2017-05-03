defmodule Nerves.Firmware.HTTP.Mixfile do
  use Mix.Project

  @version "0.3.2"

  def project do
    [app: :nerves_firmware_http,
     version: @version,
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     name: "nerves_firmware_http",
     description: "Update firmware on a Nerves device over HTTP",
     package: package(),
     docs: docs()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Nerves.Firmware.HTTP.Application, []}]
  end

  defp docs do
    [source_ref: "v#{@version}",
     main: "Nerves.Firmware.HTTP",
     source_url: "https://github.com/nerves-project/nerves_firmware_http",
     extras: [ "README.md", "CHANGELOG.md"]]
  end

  defp package do
    [maintainers: ["Justin Schneck", "Garth Hitchens"],
     licenses: ["Apache-2.0"],
     links: %{github: "https://github.com/nerves-project/nerves_firmware_http"}]
  end

  defp deps do
    [#{:nerves_firmware, "~> 0.3"},
     {:nerves_firmware, github: "nerves-project/nerves_firmware", branch: "stream"},
     {:plug, "~> 1.0"},
     {:cowboy, "~> 1.0"},
     {:exjsx, "~> 4.0", optional: true},
     {:ex_doc, "~> 0.15", only: :dev},
     {:httpotion, "~> 3.0", only: :test}]
  end
end

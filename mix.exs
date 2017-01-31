defmodule Nerves.Firmware.HTTP.Mixfile do
    use Mix.Project

    @version "0.3.0-dev"

    def project do
      [ app: :nerves_firmware_http,
        version: @version,
        elixir: "~> 1.2",
        build_embedded: Mix.env == :prod,
        start_permanent: Mix.env == :prod,
        deps: deps(Mix.env),
        name: "nerves_firmware_http",
        package: package(),
        docs: docs() ]
    end

    def application do
      [applications: [:logger, :nerves_firmware, :cowboy, :exjsx],
       mod: {Nerves.Firmware.HTTP, []}]
    end

    defp docs do
      [
        source_ref: "v#{@version}",
        main: "Nerves.Firmware.HTTP",
        source_url: "https://github.com/nerves-project/nerves_firmware_http",
        extras: [ "README.md", "CHANGELOG.md"]
      ]
    end

    defp package do
      [ maintainers: ["Garth Hitchens"],
        licenses: ["Apache-2.0"],
        links: %{github: "https://github.com/nerves-project/nerves_firmware_http"},
        files: ~w(lib config) ++ ~w(README.md CHANGELOG.md LICENSE mix.exs) ]
    end

    defp deps(:test) do
      deps(:dev) ++ [{ :httpotion, github: "myfreeweb/httpotion"}]
    end

    defp deps(_) do
      [ { :nerves_firmware, github: "nerves-project/nerves_firmware" },
        { :cowboy, "~> 1.0" },
        { :exjsx, "~> 3.2.0" },
        { :ex_doc, "~> 0.11", only: :dev} ]
    end
end
defmodule Nerves.Firmware.HTTP.Mixfile do
    use Mix.Project

    def project do
      [ app: :nerves_firmware_http,
        version: "0.2.0",
        elixir: "~> 1.2",
        build_embedded: Mix.env == :prod,
        start_permanent: Mix.env == :prod,
        deps: deps(Mix.env) ]
    end

    def application do
      [applications: [:logger, :nerves_firmware, :cowboy, :exjsx],
       mod: {Nerves.Firmware.HTTP, []}]
    end

    defp deps(:test) do
      deps(:dev) ++ [{ :httpotion, github: "myfreeweb/httpotion"}]
    end

    defp deps(_) do
      [ { :nerves_firmware, github: "ghitchens/nerves_firmware", branch: "no_http" },
        { :cowboy, "~> 1.0" },
        { :exjsx, "~> 3.2.0" },
        {:ex_doc, "~> 0.11", only: :dev} ]
    end
end
defmodule Nerves.Firmware.HTTP.Router do
  use Plug.Router
  import Nerves.Firmware.HTTP.Utils
  require Logger

  @cowboy_opts [:ip, :port, :acceptors, :max_connections, :dispatch, :ref,
                :compress, :timeout, :protocol_options]

  plug :accepts
  plug :match
  plug :dispatch

  def start_link(opts) do
    Logger.debug "Starting Firmware HTTP"
    Plug.Adapters.Cowboy.http(Nerves.Firmware.HTTP.Router, [], default_cowboy_opts(opts))
  end

  defp default_cowboy_opts(opts) do
    (opts || [])
    |> Keyword.take(@cowboy_opts)
    |> Keyword.put_new(:port, 8988)
    |> Keyword.put_new(:acceptors, 10)
    |> Keyword.put_new(:timeout, 60_000)
  end

  def accepts(conn, _) do
    case get_header(conn, "content-type") do
      "application/x-firmware" -> conn
      _ ->
        conn
        |> send_resp(400, "invalid request")
        |> halt()
    end
  end

  match "firmware", via: [:put, :post] do
    case fw_update(conn) do
      :ok ->
        conn
        |> send_resp(200, "OK")
        |> handle_reboot
      {:error, error} ->
        send_resp(conn, 500, inspect(error))
    end
  end

  get "firmware" do
    send_resp(conn, 200, encode_json(Nerves.Firmware.state))
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

end
defmodule Nerves.Firmware.HTTP.Utils do
  alias Nerves.Firmware.Fwup
  require Logger

  @chunk 1000000

  def fw_update(conn) do
    device = get_header(conn, "x-firmware-device")
    task = get_header(conn, "x-firmware-task")
    {:ok, pid} = Fwup.start_link([device: device, task: task])
    resp =
      conn
      |> Plug.Conn.read_body(length: @chunk)
      |> fw_stream(pid)
    if Process.alive?(pid) do
      Nerves.Firmware.Fwup.stop(pid)
    end
    resp
  end

  def fw_stream({:more, chunk, conn}, pid) do
    Logger.debug "Chunk Size: #{byte_size(chunk)}"
    Fwup.stream_chunk(pid, chunk)
    conn
    |> Plug.Conn.read_body(length: @chunk)
    |> fw_stream(pid)
  end
  def fw_stream({:error, _} = error, _pid) do
    error
  end
  def fw_stream({:ok, chunk, _conn}, pid) do
    Logger.debug "Chunk Size: #{byte_size(chunk)}"
    Fwup.stream_chunk(pid, chunk, await: true)
  end

  def encode_json(data) do
    json_provider =
      (Application.get_env(:nerves_firmware_http, :json_provider) || JSX)
    json_provider.encode!(data)
  end

  def get_header(conn, header) do
    case Plug.Conn.get_req_header(conn, header) do
      [""] -> nil
      [h | _] -> h
    end
  end

  def handle_reboot(conn) do
    if get_header(conn, "x-firmware-reboot") == "true" do
      Nerves.Firmware.reboot
    end
    conn
  end

end

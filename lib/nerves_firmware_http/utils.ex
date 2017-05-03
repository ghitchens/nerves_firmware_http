defmodule Nerves.Firmware.HTTP.Utils do
  alias Nerves.Firmware.Fwup

  def fw_update(conn) do
    conn
    |> fw_stream()
  end

  def fw_stream({:more, chunk, conn}, pid) do
    Fwup.stream_chunk(pid, chunk)

    conn
    |> Plug.Conn.read_body()
    |> fw_stream(pid)
  end
  def fw_stream({:ok, chunk, conn}, pid) do
    Fwup.stream_chunk(pid, chunk, await: true)
  end
  def fw_stream(conn) do
    device = get_header(conn, "x-firmware-device")
    task = get_header(conn, "x-firmware-task")
    {:ok, pid} = Fwup.start_link([device: device, task: task])
    conn
    |> Plug.Conn.read_body
    |> fw_stream(pid)
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

end

defmodule Nerves.Firmware.HTTP.Transport do

  @moduledoc false

  @max_upload_chunk 102400        # 100K max chunks to keep memory reasonable
  @max_upload_size  4294967296     # 4Gb max file

  alias Nerves.Firmware.Fwup
  require Logger

  def init(_transport, _req, _state) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def rest_init(req, handler_opts) do
    {:ok, req, handler_opts}
  end

  def allowed_methods(req, state) do
    {["GET", "PUT", "POST"], req, state}
  end

  def content_types_provided(req, state) do
    {[ {"application/json", :json_provider} ], req, state}
  end

  def content_types_accepted(req, state) do
    {[ {{"application", "x-firmware", []}, :upload_acceptor} ], req, state}
  end

  def json_provider(req, state) do
    mod = Application.get_env(:nerves_firmware_http, :json_provider, JSX)
    opts = Application.get_env(:nerves_firmware_http, :json_opts, [])
    {:ok, body} =
      Nerves.Firmware.state
      |> mod.encode(opts)
    { body <> "\n", req, state}
  end

  @doc """
  Acceptor for cowboy to update firmware via HTTP.

  Once firmware is streamed, it returns success (2XX) or failure (4XX/5XX).
  Calls `update_status()` to reflect status at `/sys/firmware`.
  Won't let you upload firmware on top of provisional (returns 403)
  """
  def upload_acceptor(req, state) do
		Logger.info "request to receive firmware"
    if Nerves.Firmware.allow_upgrade? do
      upload_and_apply_firmware_upgrade(req, state)
    else
      {:halt, reply_with(403, req), state}
		end
  end

  # TODO:  Ideally we'd like to allow streaming directly to fwup, but its hard
  # due to limitations with ports and writing to fifo's from elixir
  # Right solution would be to get Porcelain fixed to avoid golang for goon.
  defp upload_and_apply_firmware_upgrade(req, state) do
    Logger.info "receiving firmware"
    {:ok, pid} = Fwup.start_link()
    stream_fw(pid, req)
    if Process.alive?(pid), do: Fwup.stop(pid)
    Logger.info "firmware received"
    Nerves.Firmware.finalize()
    case :cowboy_req.header("x-reboot", req) do
      {:undefined, _} ->  nil
      {_, _} ->
        reply_with(200, req)
        Nerves.Firmware.reboot
    end
    {true, req, state}
  end

  # helper to return errors to requests from cowboy more easily
  defp reply_with(code, req) do
    {:ok, req} = :cowboy_req.reply(code, [], req)
    req
  end

  # copy from a cowboy req into a IO.Stream
  defp stream_fw(pid, req, count \\ 0) do
    #  send an event about (bytes_uploaded: count)
    if count > @max_upload_size do
      {:error, :too_large}
    else
      case :cowboy_req.body(req, [:length, @max_upload_chunk]) do
        {:more, chunk, new_req} ->
          Fwup.stream_chunk(pid, chunk)
          stream_fw(pid, new_req, (count + byte_size(chunk)))
        {:ok, chunk, new_req} ->
          Fwup.stream_chunk(pid, chunk, await: true)
          {:done, new_req}
      end
    end
  end
end

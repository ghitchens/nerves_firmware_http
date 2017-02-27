defmodule Nerves.Firmware.HTTP.Test do
  @moduledoc false
  use ExUnit.Case
  doctest Nerves.Firmware.HTTP
  require Logger

  @app_id :nerves_firmware_http
  @http_port Application.get_env(:nerves_firmware_http, :port, 8988)
  @http_path Application.get_env(:nerves_firmware_http, :port, "/firmware")
  @http_uri Path.join("localhost:#{@http_port}", @http_path)
  @device Application.get_env(:nerves_firmware, :device, "/tmp/test_firmware.fw")

  {:ok, _} = HTTPotion.start

  # TESTS

  test "Firmware http app started succesfully" do
    assert Application.start(@app_id) == {:error, {:already_started, @app_id}}
  end

  test "HTTP server is up and returns json response about the firmware" do
    resp = HTTPotion.get @http_uri, headers: ["Accept": "application/json"]
    headers = resp.headers.hdrs
    assert resp.status_code == 200
    assert "Cowboy" = headers["server"]
    assert "application/json" = headers["content-type"]
  end

  test "returning proper status before and after firmware upgrade" do
    fw = firmware_file("test_1.fw")
    # create the low level firmware file
    assert :ok == Nerves.Firmware.Fwup.apply(fw, @device, :complete)
    # now, test the firmware
    assert get_firmware_state()[:status] == "active"
    #now, try installing firmware upgrade
    metrics1 = read_firmware_metrics(@device)
    assert metrics1 == read_firmware_metrics(@device)
    assert 204 = send_firmware(fw)
    metrics2 = read_firmware_metrics(@device)
    assert metrics1 != metrics2
    # now that we've update firmware, we should be in await_restart state
    assert get_firmware_state()[:status] == "await_restart"
    # this should fail with 403 since firmware is not yet rebooted
    assert 403 = send_firmware(fw)
    metrics3 = read_firmware_metrics(@device)
    # and firmware should not be updated
    assert metrics2 == metrics3
    assert metrics1 != metrics3
  end

  # HELPER FUNCTIONS

  defp read_firmware_metrics(device) do
    {read_mbr(device)}
  end

  defp read_mbr(device) do
    File.open device, [:read], fn(file) ->
      IO.binread(file, 512)
    end
  end

  defp firmware_file(filename) do
    Path.join "test/firmware_files", filename
  end

  defp get_firmware_state do
    resp = HTTPotion.get @http_uri, headers: ["Accept": "application/json"]
    assert resp.status_code == 200
    json_to_term(resp)
  end

  defp send_firmware(path) do
    resp = HTTPotion.put(@http_uri, [
           body: File.read!(path),
           headers: ["Content-Type": "application/x-firmware"]])
    resp.status_code
  end

  defp json_to_term(resp) do
    assert "application/json" == resp.headers.hdrs["content-type"]
    {:ok, term} = JSX.decode(resp.body, [{:labels, :atom}])
    Enum.into term, []
  end

end

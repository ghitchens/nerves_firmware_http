defmodule Mix.Tasks.Firmware.Push do
  use Mix.Task

  @shortdoc "Pushes firmware to a Nerves device"

  @moduledoc """
  Pushes firmware to a Nerves device.

  This task will take a fw file path passed as --firmware or discover it from
  a target passed as --target.

  ## Command line options

   * `--target` - The target string of the target configuration.
   * `--firmware` - The path to a fw file.
   * `--reboot` - true / false if the target should reboot after applying firmware.

  For example, to push firmware to a device at an IP by specifying a fw file

    mix firmware.push 192.168.1.120 --firmware _images/rpi3/my_app.fw

  Or by discovering it with the target

    mix firmware.push 192.168.1.120 --target rpi3

  This task needs to run in the context of your host so it is not advised to
  pass `MIX_TARGET` or `NERVES_TARGET` in your env
  """

  @switches [firmware: :string, reboot: :string, target: :string, task: :string, device: :string]
  @chunk 10_000
  @progress_steps 25

  def run([ip | argv]) do
    {opts, _, _} = OptionParser.parse(argv, switches: @switches)
    IO.inspect opts
    body =
      firmware(opts)
      |> File.read!
    body_len = byte_size(body) |> Kernel.to_charlist
    progress = progress(byte_size(body))
    body = fn
      size when size < byte_size(body) ->
        new_size = min(size + @chunk, byte_size(body))
        chunk = new_size - size
        progress.(new_size)
        {:ok, [:binary.part(body, size, chunk)], new_size}
      _size ->
        IO.write(:stderr, "\nFirmware Uploaded. Applying...")
        :eof
    end

    reboot = opts[:reboot] || true
    task = opts[:task] || "upgrade"
    device = opts[:device] || ""
    start_httpc()
    url = "http://#{ip}:8988/firmware" |> String.to_char_list
    http_opts = [relaxed: true, autoredirect: true] #++ Nerves.Utils.Proxy.config(url)
    opts = [body_format: :binary]

    headers = %{
      'x-firmware-reboot' => '#{reboot}',
      'x-firmware-task' => '#{task}',
      'x-firmware-device' => '#{device}',
      'content-length' => body_len} |> Map.to_list
    :httpc.request(:post, {url, headers, 'application/x-firmware', {body, 0}}, http_opts, opts, :nerves_firmware)
    |> response
  end

  defp start_httpc() do
    Application.ensure_started(:inets)
    Application.ensure_started(:ssl)
    :inets.start(:httpc, profile: :nerves_firmware)

    opts = [
      max_sessions: 8,
      max_keep_alive_length: 4,
      max_pipeline_length: 4,
      keep_alive_timeout: 120_000,
      pipeline_timeout: 60_000
    ]
    :httpc.set_options(opts, :nerves_firmware)
  end

  def response({:ok, {{_, 200, _}, _, _}}) do
    Mix.shell.info "Done"
  end

  def response({:ok, {{_, status_code, _}, _, error}}) do
    Mix.shell.info "\nThere was an error applying the firmware: #{inspect status_code} #{inspect error}"
  end

  def response({:error, error}) do
    Mix.shell.info "\nThere was an error applying the firmware: #{inspect error}"
  end

  #find the firmware

  defp firmware(opts) do
    if fw = opts[:firmware] do
      fw |> Path.expand
    else
      discover_firmware(opts)
    end
  end

  defp discover_firmware(opts) do
    target = opts[:target] || Mix.raise """
    You must pass either firmware or target
    Examples:
      $ mix firmware.push 192.168.1.100 --firmware path/to/app.fw
      $ mix firmware.push 192.168.1.100 --target rpi3
    """
    project = Mix.Project.get
    :code.delete(project)
    :code.purge(project)
    level = Logger.level
    Logger.configure(level: :error)
    Application.stop(:mix)
    System.put_env("MIX_TARGET", target)
    Application.start(:mix)
    Logger.configure(level: level)
    Mix.Project.in_project(project, File.cwd!, fn(_module) ->

      target = Mix.Project.config[:target]
      app = Mix.Project.config[:app]
      images_path =
        (Mix.Project.config[:images_path] ||
        Path.join([Mix.Project.build_path, "nerves", "images"]) ||
        "_images/#{target}")
      Path.join([images_path, "#{app}.fw"])
      |> Path.expand
    end)
  end

  def progress(nil) do
    fn _ -> nil end
  end

  def progress(max) do
    put_progress(0, 0)

    fn size ->
      fraction = size / max
      completed = trunc(fraction * @progress_steps)
      put_progress(completed, trunc(fraction * 100))
      size
    end
  end

  defp put_progress(completed, percent) do
    unfilled = @progress_steps - completed
    IO.write(:stderr, "\r|#{String.duplicate("=", completed)}#{String.duplicate(" ", unfilled)}| #{percent}% ")
  end
end

defmodule Cometoid.CodeAdapter do

  def open_in_editor(path, id, type, title) do
    heading = "#{String.upcase(type)} (Id: #{id}) - #{title}"
    spawn(fn ->
      unless File.exists? path do
        File.write(path, "# #{heading}")
      else
        System.cmd("sed", ["-i",
          "1s/^#.*$/# #{heading}/", path])
      end
      System.cmd("code", [path])
    end)
  end

  def delete path do
    File.rm path
  end

  def read_from_editor(path) do
    if File.exists? path do
      {:ok, contents} = File.read path
      [first_line | lines] = contents
      |> String.split("\n")
      if String.starts_with?(first_line, "#") do
        Enum.join(lines, "\n")
      else
        contents
      end
    else
      ""
    end
  end
end

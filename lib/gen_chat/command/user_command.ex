defmodule GenChat.Command.UserCommand do
  require Logger

  @three_parts [:PUBLIC, :PRIVATE]
  @two_parts [:EXIT, :ENTER, :LIST_USERS, :REGISTER, :CREATE]
  @singles [:DISCONNECT, :LIST_ROOMS, :WHOAMI]

  def parse(line) do
    String.split(line)
    |> to_command_tuple
  end

  defp to_command_tuple([command | tail]) do
    safe_command = convert_to_atom(command)

    cond do
      safe_command in @three_parts and Enum.count(tail) >= 2 ->
        [target | rest] = tail
        {safe_command, target, Enum.join(rest, " ")}

      safe_command in @two_parts and Enum.count(tail) == 1 ->
        [target] = tail
        {safe_command, target}

      safe_command in @singles ->
        {safe_command}

      true ->
        {:error, "Unknown command! #{command}"}
    end
  end

  defp convert_to_atom(command) do
    try do
      String.to_existing_atom(command)
    rescue
      e in ArgumentError ->
        Logger.info("Could not parse command #{inspect e}")
        false
    end
  end
end

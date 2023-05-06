defmodule Chat.Command.CommandDispatcher do
  require Logger
  
  def dispatch({channel, proxy}, command) do
    {status, message} =
      case command do
        {:REGISTER, _} ->
          Chat.Command.Executor.handle_register_command({channel, proxy}, command)

        _ ->
          Logger.warn("Unknown command: #{command}")
          {:error, "Unknown command."}
      end

    proxy.send(channel, message)
    {status, message}
  end
end

defmodule Chat.Command.CommandDispatcher do
  alias Chat.Comm.Message

  def dispatch(socket, command) do
    {status, message} =
      case command do
        {:REGISTER, _} ->
          Chat.Command.Executor.handle_user_command(socket, command)

        _ ->
          {:error, "Unknown command."}
      end

    Message.send(socket, message)
    {status, message}
  end
end

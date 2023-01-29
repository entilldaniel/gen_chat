defmodule Chat.Command.Executor do
  require Logger

  def handle_user_command(from, {command, target, value}) do
    Logger.info("in handle user command")
    case command do
      :PUBLIC -> Logger.info("Not implemented")
      :PRIVATE ->
        [{pid, nil}] = Registry.lookup(Registry.Users, target)
        Logger.info("#{target} PID #{inspect(pid)}")
        Chat.User.send_message(pid, {from, value})
    end
    :ok
  end

  def handle_user_command(from, {command, target}) do
    :ok
  end

  def handle_user_command(from, {command}) do
    :ok
  end
  
end

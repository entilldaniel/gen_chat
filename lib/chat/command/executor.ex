defmodule Chat.Command.Executor do
  require Logger

  def handle_user_command(from, {command, target, value}) do
    case command do
      :PUBLIC -> 
        [{pid, nil}] = Registry.lookup(Registry.Rooms, target)
        Chat.Room.send_message(pid, {from, value})
      :PRIVATE ->
        [{pid, nil}] = Registry.lookup(Registry.Users, target)
        Chat.User.send_message(pid, {from, value})
    end
    :ok
  end

  def handle_user_command(from, {command, target}) do
    case command do
      :EXIT -> Logger.info("NOT IMPLEMENTED")
      :ENTER -> Logger.info("NOT IMPLEMENTED")
      :LIST_USERS -> Logger.info("NOT IMPLEMENTED")
      :REGISTER -> Logger.info("NOT IMPLEMENTED")
      :CREATE -> Logger.info("NOT IMPLEMENTED")
    end
  end

  def handle_user_command(from, {command}) do
    case command do
      :QUIT -> Logger.info("NOT IMPLEMENTED")
      :LIST_ROOMS -> Logger.info("NOT IMPLEMENTED")
    end
  end
  
end

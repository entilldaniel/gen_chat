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
      :CREATE -> create_room(from, target)
      :EXIT -> Logger.info("NOT IMPLEMENTED")
      :ENTER -> Logger.info("NOT IMPLEMENTED")
      :LIST_USERS -> Logger.info("NOT IMPLEMENTED")
      :REGISTER -> Logger.info("NOT IMPLEMENTED")
    end
  end

  def handle_user_command(from, {command}) do
    Logger.info("command from: #{inspect from}")
    case command do
      :QUIT -> Logger.info("NOT IMPLEMENTED")
      :LIST_ROOMS -> Logger.info("NOT IMPLEMENTED")
    end
  end

  defp create_room(user_handle, name) do
    case Registry.lookup(Registry.Rooms, name) do
      [{_, nil}] ->
        {:ok, nil}

      _ ->
        Chat.RoomSupervisor.add_room(name)
        Logger.info("Room #{name} created by #{user_handle}.")
        {:ok, :handled}
    end
  end
end

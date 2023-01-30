defmodule Chat.Command.Executor do
  require Logger

  def handle_user_command(_pid, from, {command, target, value}) do
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

  def handle_user_command(_pid, from, {command, target}) do
    case command do
      :CREATE -> create_room(from, target)
      :EXIT -> Logger.info("NOT IMPLEMENTED")
      :ENTER -> enter_room(from, target)
      :LIST_USERS -> list_users(from, target)
      :REGISTER -> Logger.info("NOT IMPLEMENTED HERE")
    end
  end

  def handle_user_command(_pid, from, {command}) do
    Logger.info("command from: #{inspect from}")
    case command do
      :QUIT -> Logger.info("NOT IMPLEMENTED")
      :LIST_ROOMS -> Logger.info("NOT IMPLEMENTED")
    end
  end

  defp enter_room(user_handle, room) do
    Logger.info("Entering the room")
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

  defp list_users(from, room) do
    case Registry.lookup(Registry.Rooms, room) do
      [{_pid, _}] ->
        Logger.info("Found room #{room} for #{from}")
        _ -> Logger.info("No room by that name.")
    end
  end
end

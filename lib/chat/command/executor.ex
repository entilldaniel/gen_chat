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
      :EXIT -> leave_room(from, target)
      :ENTER -> enter_room(from, target)
      :LIST_USERS -> list_users(from, target)
      :REGISTER -> Logger.info("NOT IMPLEMENTED HERE")
    end
  end

  def handle_user_command(_pid, _from, {command}) do
    case command do
      :DISCONNECT -> Logger.info("NOT IMPLEMENTED")
      :LIST_ROOMS -> list_rooms()
    end
  end

  defp leave_room(from, target) do
    case Registry.lookup(Registry.Rooms, target) do
      [{pid, _}] ->
        {:ok, Chat.Room.leave_room(pid, from)}
      _ ->
        Logger.info("No room by that name.")
        {:nok, "room #{target} not found."}
    end
  end

  defp list_users(from, room) do
    case Registry.lookup(Registry.Rooms, room) do
      [{pid, _}] ->
        Logger.info("Found room #{room} for #{from}")
        {:ok, Chat.Room.list_users(pid)}

      _ ->
        Logger.info("No room by that name.")
        {:nok, "room #{room} not found."}
    end
  end

  defp list_rooms() do
    keys = Registry.select(Registry.Rooms, [{{:"$1", :_, :_}, [], [:"$1"]}])
    {:ok, keys}
  end

  defp enter_room(user_handle, room) do
    Logger.info("Entering the room")
    case Registry.lookup(Registry.Rooms, room) do
      [{pid, nil}] ->
        result = Chat.Room.enter_room(pid, user_handle)
        {:ok, "entered room #{room}, here are the people #{result}"}
      _ ->
        {:error, "Room #{room} not found."}
    end
  end

  defp create_room(user_handle, name) do
    case Registry.lookup(Registry.Rooms, name) do
      [{_, nil}] ->
        {:nok, "Room #{name} already exists."}

      _ ->
        Chat.RoomSupervisor.add_room(name)
        Logger.info("Room #{name} created by #{user_handle}.")
        {:ok, "Room created."}
    end
  end
end

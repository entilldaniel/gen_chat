defmodule Chat.Command.Executor do
  require Logger

  def handle_register_command(context, {_command, handle}) do
    register(context, handle)
  end
  
  def handle_user_command(context, {command, target, value}) do
    case command do
      :PUBLIC -> send_room_message(context, target, value)
      :PRIVATE -> send_private_message(context, target, value)
    end
  end

  def handle_user_command(context, {command, target}) do
    case command do
      :CREATE -> create_room(context, target)
      :EXIT -> leave_room(context, target)
      :ENTER -> enter_room(context, target)
      :LIST_USERS -> list_users(context, target)
    end
  end

  def handle_user_command(payload, {command}) do
    case command do
      :DISCONNECT -> disconnect(payload)
      :LIST_ROOMS -> list_rooms()
      :WHOAMI -> whoami(payload)
    end
  end

  defp send_room_message(sender, target, message) do
    case Registry.lookup(Registry.Rooms, target) do
      [{pid, nil}] ->
        message = "Room: #{target}\nSENDER: #{sender}\n#{message}"
        Chat.Room.send_message(pid, {sender, message})
        {:ok, "OK"}

      _ ->
        {:error, "Room #{target} not found."}
    end
  end

  defp send_private_message(sender, target, message) do
    case Registry.lookup(Registry.Users, target) do
      [{pid, nil}] ->
        message = "MESSAGE FROM #{sender}\n#{message}"
        Chat.User.send_message(pid, message)
        {:ok, "OK"}

      _ ->
        {:error, "User #{target} not found."}
    end
  end

  defp register({channel, proxy}, handle) do
    Logger.info("Registering user #{handle}")
    case Registry.lookup(Registry.Users, handle) do
      [{_, nil}] ->
        {:error, "Handle (#{handle}) already taken"}

      [] ->
        Chat.UserSupervisor.add_user({handle, {channel, proxy}})
        {:ok, "OK, #{handle} REGISTERED"}
    end
  end

  defp leave_room(handle, target) do
    case Registry.lookup(Registry.Rooms, target) do
      [{pid, _}] ->
        Chat.Room.leave_room(pid, handle)
        {:ok, "OK"}

      _ ->
        {:error, "Room #{target} not found."}
    end
  end

  defp list_users(_from, target) do
    case Registry.lookup(Registry.Rooms, target) do
      [{pid, _}] ->
        users = Enum.join(Chat.Room.list_users(pid), ", ")
        {:ok, users}

      _ ->
        {:error, "Room #{target} not found."}
    end
  end

  defp list_rooms() do
    keys = Registry.select(Registry.Rooms, [{{:"$1", :_, :_}, [], [:"$1"]}])

    {:ok, Enum.join(keys, ", ")}
  end

  defp enter_room(user_handle, target) do
    case Registry.lookup(Registry.Rooms, target) do
      [{pid, nil}] ->
        result = Enum.join(Chat.Room.enter_room(pid, user_handle), ", ")
        {:ok, "entered room #{target}, here are the people #{result}."}

      _ ->
        {:error, "Room #{target} not found."}
    end
  end

  defp create_room(handle, name) do
    case Registry.lookup(Registry.Rooms, name) do
      [{_, nil}] ->
        {:error, "Room #{name} already exists."}

      _ ->
        Chat.RoomSupervisor.add_room(name, handle)
        {:ok, "Room created."}
    end
  end

  defp whoami(handle) do
    case Registry.lookup(Registry.Users, handle) do
      [{pid, nil}] ->
        result = Chat.User.whoami(pid)
        {:ok, result}

      _ ->
        {:error, "You don't exist."}
    end
  end

  defp disconnect(handle) do
    case Registry.lookup(Registry.Users, handle) do
      [{pid, nil}] ->
        Chat.User.disconnect(pid)
    end
  end
end

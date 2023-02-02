defmodule Chat.Command.Executor do
  require Logger
  
  def handle_user_command(payload, {command, target, value}) do
    case command do
      :PUBLIC -> send_room_message(payload, target, value)
      :PRIVATE -> send_private_message(payload, target, value)
    end
  end

  def handle_user_command(payload, {command, target}) do
    case command do
      :CREATE -> create_room(payload, target)
      :EXIT -> leave_room(payload, target)
      :ENTER -> enter_room(payload, target)
      :LIST_USERS -> list_users(payload, target)
      :REGISTER -> register(payload, target)
    end
  end

  def handle_user_command(_payload, {command}) do
    case command do
      :DISCONNECT -> Logger.info("NOT IMPLEMENTED")
      :LIST_ROOMS -> list_rooms()
    end
  end

  defp send_room_message(sender, target, message) do
      case Registry.lookup(Registry.Rooms, target) do
        [{pid, nil}] -> Chat.Room.send_message(pid, {sender, message})
        _ -> {:error, "Room #{target} not found."}
      end
  end

  defp send_private_message(sender, target, message) do
    case Registry.lookup(Registry.Users, target) do
      [{pid, nil}] -> Chat.User.send_message(pid, {sender, message})
      _ -> {:error, "User #{target} not found."}
    end
    
  end

  defp register(socket, handle) do
    case Registry.lookup(Registry.Users, handle) do
      [{_, nil}] ->
        {:error, "Handle (#{handle}) already taken"}

      [] ->
        Chat.UserSupervisor.add_user({handle, socket})
        {:ok, "OK, #{handle} REGISTERED"}
    end
  end

  defp leave_room(from, target) do
    case Registry.lookup(Registry.Rooms, target) do
      [{pid, _}] -> {:ok, Chat.Room.leave_room(pid, from)}
      _ -> {:error, "Room #{target} not found."}
    end
  end

  defp list_users(_from, target) do
    case Registry.lookup(Registry.Rooms, target) do
      [{pid, _}] -> {:ok, Chat.Room.list_users(pid)}
      _ -> {:error, "Room #{target} not found."}
    end
  end

  defp list_rooms() do
    keys = Registry.select(Registry.Rooms, [{{:"$1", :_, :_}, [], [:"$1"]}])
    {:ok, keys}
  end

  defp enter_room(user_handle, target) do
    case Registry.lookup(Registry.Rooms, target) do
      [{pid, nil}] ->
        result = Chat.Room.enter_room(pid, user_handle)
        {:ok, "entered room #{target}, here are the people #{result}."}

      _ -> {:error, "Room #{target} not found."}
    end
  end

  defp create_room(_user_handle, name) do
    case Registry.lookup(Registry.Rooms, name) do
      [{_, nil}] ->
        {:error, "Room #{name} already exists."}

      _ ->
        Chat.RoomSupervisor.add_room(name)
        {:ok, "Room created."}
    end
  end
end

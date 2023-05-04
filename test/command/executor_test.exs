defmodule Command.ExecutorTest do
  use ExUnit.Case
  alias Chat.Command.Executor

  test "Can create rooms" do
    room = "test-create-room"
    {_status, _pid} = Chat.UserSupervisor.add_user({"create-room-user", nil})
    {status, message} = Executor.handle_user_command("create-room-user", {:CREATE, room})
    assert status == :ok
    assert message == "Room created."

    {status, message} = Executor.handle_user_command("create-room-user", {:CREATE, room})
    assert status == :error
    assert message == "Room #{room} already exists."
  end

  test "Can list rooms" do
    {_status, _pid} = Chat.UserSupervisor.add_user({"list-room-user", nil})
    Executor.handle_user_command("list-room-user", {:CREATE, "test-attic"})
    {status, result} = Executor.handle_user_command("list_room-user", {:LIST_ROOMS})

    assert :ok == status
    assert true == String.contains?(result, "test-attic")
  end

  test "Can list users in a room" do
    room_name = "test-list-users-dungeon"
    {_status, _pid} = Chat.UserSupervisor.add_user({"room-user", nil})
    Executor.handle_user_command("room-user", {:CREATE, room_name})
    Executor.handle_user_command("room-user", {:ENTER, room_name})

    {status, result} = Executor.handle_user_command("room-user", {:LIST_USERS, room_name})
    assert :ok == status
    assert result == "room-user"
  end
end

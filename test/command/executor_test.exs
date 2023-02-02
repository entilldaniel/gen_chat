defmodule Command.ExecutorTest do
  use ExUnit.Case
  alias Chat.Command.Executor

  test "Can create rooms" do
    {status, message} = Executor.handle_user_command(nil, "test", {:CREATE, "test-create-room"})
    assert status == :ok
    assert message == "Room created."

    {status, message} = Executor.handle_user_command(nil, "test", {:CREATE, "test-create-room"})
    assert status == :nok
    assert message == "Room test-create-room already exists."
  end

  test "Can list rooms" do
    Executor.handle_user_command(nil, "test", {:CREATE, "test-attic"})
    {status, result} = Executor.handle_user_command(nil, "test", {:LIST_ROOMS})

    rooms =
      result
      |> Enum.filter(fn x -> x == "test-attic" end)
      |> Enum.count()

    assert :ok == status
    assert 1 == rooms
  end

  test "Can list users in a room" do
    room_name = "test-list-users-dungeon"
    {status, _pid} = Chat.UserSupervisor.add_user({"room-user", nil})
    Executor.handle_user_command(nil, "room-user", {:CREATE, room_name})
    Executor.handle_user_command(nil, "room-user", {:ENTER, room_name})

    {status, result} = Executor.handle_user_command(nil, "room-user", {:LIST_USERS, room_name})
    assert :ok == status
    assert result == ["room-user"]
  end
end

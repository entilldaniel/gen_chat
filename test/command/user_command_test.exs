defmodule Command.UserCommandTest do
  use ExUnit.Case

  test "can parse threeple" do
    line = "PUBLIC lobby hello everyone!"
    {command, room, message} = GenChat.Command.UserCommand.parse(line)
    assert command == :PUBLIC
    assert room == "lobby"
    assert message == "hello everyone!"
  end

  test "can parse tuple" do
    line = "EXIT lobby"
    {command, room} = GenChat.Command.UserCommand.parse(line)
    assert command == :EXIT
    assert room == "lobby"
  end

  test "can parse singles" do
    line = "DISCONNECT"
    {command} = GenChat.Command.UserCommand.parse(line)
    assert command == :DISCONNECT
  end
end

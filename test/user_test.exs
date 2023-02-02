defmodule UserTest do
  use ExUnit.Case
  require Logger

  test "Create a new User" do
    {status, _pid} = Chat.UserSupervisor.add_user({"Test", nil})
    assert status == :ok
  end
 end

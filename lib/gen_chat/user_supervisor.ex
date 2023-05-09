defmodule GenChat.UserSupervisor do
  use DynamicSupervisor
  require Logger
  
  def start_link(arg) do
    Logger.info("Starting UserSupervisor")
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end
  
  def init(_arg),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def add_user(data),
    do: DynamicSupervisor.start_child(__MODULE__, {GenChat.User, data})

end

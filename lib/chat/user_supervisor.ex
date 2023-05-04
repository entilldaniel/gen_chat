defmodule Chat.UserSupervisor do
  use DynamicSupervisor

  def start_link(arg),
    do: DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)

  def init(_arg),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def add_user(data),
    do: DynamicSupervisor.start_child(__MODULE__, {Chat.User, data})

end

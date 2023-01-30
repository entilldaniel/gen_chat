defmodule Chat.RoomSupervisor do
  use DynamicSupervisor

  def start_link(arg),
    do: DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)

  def init(_arg),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def add_room(data),
    do: DynamicSupervisor.start_child(__MODULE__, {Chat.Room, data})

  
end

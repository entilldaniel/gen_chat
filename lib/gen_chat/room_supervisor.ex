defmodule GenChat.RoomSupervisor do
  use DynamicSupervisor
  require Logger
  
  def start_link(arg) do
    Logger.info("Starting RoomSupervisor")
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def add_room(name, handle),
    do: DynamicSupervisor.start_child(__MODULE__, {GenChat.Room, {name, handle}})

  def get_room_by_name(name) do
    case Registry.lookup(Registry.Rooms, name) do
      [{pid, _}] ->
        {:ok, pid}
      _ ->
        {:error, "Room #{name} not found."}
    end
  end

end

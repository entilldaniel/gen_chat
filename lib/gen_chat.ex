defmodule GenChat do
  require Logger
  
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end
  
  def start_link() do
    Logger.info("Starting GenChat")
    children = [
      {Registry, keys: :unique, name: Registry.Users},
      {GenChat.UserSupervisor, []},
      {Registry, keys: :unique, name: Registry.Rooms},
      {GenChat.RoomSupervisor, []}
    ]

    opts = [name: GenChat.Supervisor, strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
  
  
end

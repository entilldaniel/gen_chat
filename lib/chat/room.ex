defmodule Chat.Room do
  use GenServer
  require Logger
  
  defstruct name: nil, users: []

  def start_link(name) do
    Logger.info("Call to start link #{name}")
    GenServer.start_link(__MODULE__, name, name: process_name(name))
  end

  defp process_name(name), do: {:via, Registry, {Registry.Rooms, name}}

  def send_message(pid, envelope), do: GenServer.cast(pid, {:message, envelope})

  @impl true
  def init(name) do
    Logger.info("in room init")
    state = %__MODULE__{name: name}
    {:ok, state}
  end
  
  @impl true
  def handle_cast({:join, handle}, state) do
    Logger.info("Failing")
    state = %{state | :users => [handle|state.users]}
    {:noreply, state}
  end
  
end

defmodule Chat.Room do
  use GenServer
  require Logger

  defstruct name: nil, users: []

  def enter_room(pid, user_handle), do: GenServer.call(pid, {:enter, user_handle})
  def send_message(pid, envelope), do: GenServer.cast(pid, {:message, envelope})
  def list_users(pid), do: GenServer.call(pid, :list)
  def leave_room(pid, user_handle), do: GenServer.cast(pid, {:leave, user_handle})

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: process_name(name))
  end

  defp process_name(name), do: {:via, Registry, {Registry.Rooms, name}}

  @impl true
  def init(name) do
    state = %__MODULE__{name: name}
    {:ok, state}
  end

  @impl true
  def handle_cast({:join, handle}, state) do
    state = %{state | :users => [handle | state.users]}
    {:noreply, state}
  end

  @impl true
  def handle_cast({:leave, handle}, state) do
    users =
      state.users
      |> Enum.filter(fn u -> u != handle end)
    
    state = %{state | :users => users}
    {:noreply, state}
  end

  @impl true
  def handle_call(:list, _from, state) do
    Logger.info("listing users #{inspect(state.users)} in room #{state.name}")
    {:reply, state.users, state}
  end

  @impl true
  def handle_call({:enter, handle}, _from, state) do
    Logger.info("User #{handle} has entered the room #{state.name}")
    state = %{state | :users => Enum.uniq([handle | state.users])}
    {:reply, state.users, state}
  end
end

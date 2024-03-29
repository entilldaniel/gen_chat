defmodule GenChat.Room do
  use GenServer
  require Logger

  @type t :: %__MODULE__{
    name: String.t(),
    users: [String.t()]
  }
  defstruct name: nil, users: []


  @spec enter_room(pid, String.t) :: any()
  def enter_room(pid, user_handle), do: GenServer.call(pid, {:enter, user_handle})

  @spec send_message(pid, {String.t, String.t}) :: any()
  def send_message(pid, envelope), do: GenServer.cast(pid, {:message, envelope})

  @spec list_users(pid) :: any
  def list_users(pid), do: GenServer.call(pid, :list)
  
  @spec leave_room(pid, String.t) :: :ok
  def leave_room(pid, user_handle), do: GenServer.cast(pid, {:leave, user_handle})

  @spec start_link({String.t(), any}) :: :ignore | {:error, any} | {:ok, pid}
  def start_link({name, _} = data) do
    GenServer.start_link(__MODULE__, data, name: via_tuple(name))
  end

  @spec via_tuple(String.t()) :: {:via, module(), {module(), String.t()}}
  defp via_tuple(name), do: {:via, Registry, {Registry.Rooms, name}}

  @impl true
  def init({name, handle}) do
    state = %__MODULE__{name: name, users: [handle]}
    [{pid, _}] = Registry.lookup(Registry.Users, handle)
    GenChat.User.add_room(pid, state.name)
    {:ok, state}
  end

  @impl true
  def handle_call(:list, _from, state) do
    Logger.info("listing users #{inspect(state.users)} in room #{state.name}")
    {:reply, state.users, state}
  end

  @impl true
  def handle_call({:enter, handle}, _from, state) do
    state = %{state | :users => Enum.uniq([handle | state.users])}
    [{pid, _}] = Registry.lookup(Registry.Users, handle)
    GenChat.User.add_room(pid, state.name)
    {:reply, state.users, state}
  end

  @impl true
  def handle_cast({:message, {handle, message}}, state) do
    if handle in state.users do
      Enum.each(state.users, fn user ->
        case Registry.lookup(Registry.Users, user) do
          [{pid, _}] ->
            GenChat.User.send_message(pid, message)

          _ ->
            Logger.info("User #{user} not found.")
        end
      end)
    else
      Logger.info("User #{handle} isn't in this room")
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast({:leave, handle}, state) do
    users =
      state.users
      |> Enum.filter(fn u -> u != handle end)

    state = %{state | :users => users}

    if Enum.empty?(state.users) do
      Logger.info("Room #{state.name} is empty, shutting down...")
      DynamicSupervisor.terminate_child(GenChat.RoomSupervisor, self())
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end
end


defmodule GenChat.User do
  use GenServer
  require Logger

  defstruct handle: nil, rooms: [], channel: nil, proxy: nil

  def start_link({name, _} = data) do
    GenServer.start_link(__MODULE__, data, name: process_name(name))
  end

  defp process_name(name), do: {:via, Registry, {Registry.Users, name}}

  def send_command(pid, command), do: GenServer.cast(pid, {:command, command})
  def send_message(pid, message), do: GenServer.cast(pid, {:message, message})
  def whoami(pid), do: GenServer.call(pid, :whoami)
  def add_room(pid, room), do: GenServer.cast(pid, {:room, room})
  def disconnect(pid), do: GenServer.cast(pid, :disconnect)

  @impl true
  def init({name, {channel, proxy}}) do
    Logger.info("Creating user with handle: #{name}")
    state = %__MODULE__{handle: name, channel: channel, proxy: proxy}
    {:ok, state, {:continue, :user}}
  end

  @impl true
  def handle_continue(:user, state) do
    state.proxy.send(state.channel, "Welcome #{state.handle}! You are registered!")
    # Is this a memory leak?
    Task.async(fn -> handle_input(state) end)
    {:noreply, state}
  end

  defp handle_input(state) do
    case state.proxy.receive(state.channel) do
      {:ok, data} ->
        {_, message} =
          case GenChat.Command.UserCommand.parse(data) do
            {:error, reason} ->
              {:error, reason}

            command ->
              GenChat.Command.Executor.handle_user_command(state.handle, command)
          end

        state.proxy.send(state.channel, message)
        handle_input(state)

      :continue ->
        handle_input(state)

      {:error, _} ->
        Logger.warn("Got an error, shutting down self: #{inspect(self())}")
        DynamicSupervisor.terminate_child(GenChat.UserSupervisor, self())
    end
  end

  @impl true
  def handle_cast(:disconnect, state) do
    for room <- state.rooms do
      case GenChat.RoomSupervisor.get_room_by_name(room) do
        {:ok, pid} -> GenChat.Room.leave_room(pid, state.handle)
      end
    end

    DynamicSupervisor.terminate_child(GenChat.UserSupervisor, self())
    {:noreply, nil}
  end

  @impl true
  def handle_cast({:message, message}, state) do
    state.proxy.send(state.channel, message)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:room, room}, state) do
    state = %{state | :rooms => Enum.uniq([room | state.rooms])}
    {:noreply, state}
  end

  @impl true
  def handle_call(:whoami, _from, state) do
    message = "HANDLE: #{state.handle}\nROOMS: #{state.rooms}\n"
    {:reply, message, state}
  end

end

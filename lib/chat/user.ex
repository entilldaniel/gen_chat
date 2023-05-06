defmodule Chat.User do
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

  @impl true
  def init({name, {channel, proxy}}) do
    state = %__MODULE__{handle: name, channel: channel, proxy: proxy}
    {:ok, state, {:continue, :user}}
  end

  @impl true
  def handle_continue(:user, state) do
    state.proxy.send(state.channel, "Welcome #{state.handle}! You are registered!")
    Task.async(fn -> handle_input(state) end)
    {:noreply, state}
  end

  defp handle_input(state) do
    case state.proxy.receive(state.channel) do
      {:ok, data} ->
        {_, message} =
          case Chat.Command.UserCommand.parse(data) do
            {:error, reason} ->
              {:error, reason}

            command ->
              Chat.Command.Executor.handle_user_command(state.handle, command)
          end

        state.proxy.send(state.channel, message)
    end

    handle_input(state)
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

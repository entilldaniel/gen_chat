defmodule Chat.User do
  use GenServer
  require Logger

  defstruct handle: nil, rooms: [], socket: nil

  def start_link({name, _} = data) do
    GenServer.start_link(__MODULE__, data, name: process_name(name))
  end

  defp process_name(name), do: {:via, Registry, {Registry.Users, name}}

  def send_command(pid, command), do: GenServer.cast(pid, {:command, command})
  def send_message(pid, message), do: GenServer.cast(pid, {:message, message})

  @impl true
  def init({name, socket}) do
    state = %__MODULE__{handle: name, socket: socket}
    {:ok, state, {:continue, :user}}
  end

  @impl true
  def handle_continue(:user, state) do
    :gen_tcp.send(state.socket, "Welcome #{state.handle}! You are registered!\n\n")
    Logger.info("#{state.handle} - #{inspect(self())}")
    Task.async(fn -> handle_input(self(), state) end)
    {:noreply, state}
  end

  defp handle_input(pid, state) do
    case :gen_tcp.recv(state.socket, 0, 10_000) do
      {:ok, data} ->
        case Chat.Command.UserCommand.parse(data) do
          {:error, reason} ->
            :gen_tcp.send(state.socket, reason)

          command ->
            Logger.info("Handling command #{inspect(command)}")
            {_, result} = Chat.Command.Executor.handle_user_command(pid, state.handle, command)
            :gen_tcp.send(state.socket, "#{inspect(result)}\n")
        end
      {:error, :timeout} ->
        :ok

      {:error, _} ->
        :stop
    end

    handle_input(pid, state)
  end

  @impl true
  def handle_cast({:message, envelope}, state) do
    {sender, message} = envelope
    :gen_tcp.send(state.socket, "MESSAGE FROM: #{sender}\n\n#{message}")
    {:noreply, state}
  end
end

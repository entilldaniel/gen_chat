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
    :gen_tcp.send(socket, "User #{name} registered\r\n\r\n")
    {:ok, state, {:continue, :user}}
  end

  @impl true
  def handle_continue(:user, state) do
    Logger.info("#{state.handle} - #{inspect(self())}")
    Task.async(fn -> handle_input(state) end)
    {:noreply, state}
  end

  defp handle_input(state) do
    case :gen_tcp.recv(state.socket, 0, 10_000) do
      {:ok, data} ->
        case Chat.Command.UserCommand.parse(data) do
          {:error, reason} ->
            Logger.warn("Could not parse: #{inspect(reason)}}")
            :gen_tcp.send(state.socket, reason)

          command ->
            Logger.info("THE COMMAND WAS #{inspect(command)}")
            Chat.Command.Executor.handle_user_command(state.handle, command)
        end

        {:noreply, state, {:continue, :user}}

      {:error, :timeout} ->
        {:noreply, state, {:continue, :user}}

      {:error, _} ->
        {:stop, :normal}
    end
    handle_input(state)
  end

  @impl true
  def handle_cast({:message, envelope}, state) do
    Logger.info("handling cast")
    {sender, message} = envelope
    :gen_tcp.send(state.socket, "MESSAGE FROM: #{sender}\n\n#{message}")
    {:noreply, state}
  end
end

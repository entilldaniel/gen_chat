defmodule Chat.User do
  use GenServer
  require Logger
  alias Chat.Comm.Message

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
    Message.send(state.socket, "Welcome #{state.handle}! You are registered!")
    Task.async(fn -> handle_input(state) end)
    {:noreply, state}
  end

  defp handle_input(state) do
    case :gen_tcp.recv(state.socket, 0, 10_000) do
      {:ok, data} ->
        {_, message} =
          case Chat.Command.UserCommand.parse(data) do
            {:error, reason} ->
              {:error, reason}

            command ->
              Chat.Command.Executor.handle_user_command(state.handle, command)
          end

        Message.send(state.socket, message)

      {:error, :timeout} ->
        :ok

      {:error, _} ->
        :stop
    end

    handle_input(state)
  end

  @impl true
  def handle_cast({:message, message}, state) do
    Message.send(state.socket, message)
    {:noreply, state}
  end
end

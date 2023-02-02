defmodule Chat.EntryServer do
  use GenServer
  alias Chat.Comm.Message
  require Logger

  defstruct [:listen_socket, :supervisor]

  def start_link([] = _opts) do
    GenServer.start_link(__MODULE__, :no_state)
  end

  @impl true
  def init(:no_state) do
    {:ok, supervisor} = Task.Supervisor.start_link()

    options = [
      mode: :binary,
      active: false,
      reuseaddr: true
    ]

    port = Application.fetch_env!(:chat, :port)
    Logger.info("Starting chat on port #{port}")

    case :gen_tcp.listen(port, options) do
      {:ok, socket} ->
        state = %__MODULE__{listen_socket: socket, supervisor: supervisor}
        {:ok, state, {:continue, :accept}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_continue(:accept, %__MODULE__{} = state) do
    case :gen_tcp.accept(state.listen_socket) do
      {:ok, socket} ->
        Logger.info("new connection")
        Task.Supervisor.start_child(state.supervisor, fn -> handle_connection(socket) end)
        {:noreply, state, {:continue, :accept}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  defp handle_connection(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        case handle_message(socket, data) do
          {:ok, :handled} -> {:stop, :normal}
          {:ok, _} -> handle_connection(socket)
        end

      {:error, reason} ->
        Logger.info("Dropped connection #{inspect(reason)}")
        :gen_tcp.close(socket)
        {:error, reason}
    end
  end

  def handle_message(socket, data) do
    Logger.info("#{inspect(data)}")
    command = Chat.Command.UserCommand.parse(data)

    {_, message} =
      case command do
        {:REGISTER, _} ->
          Chat.Command.Executor.handle_user_command(socket, command)

        _ ->
          {:error, "Unknown command."}
      end
    Message.send(socket, message)
  end
end

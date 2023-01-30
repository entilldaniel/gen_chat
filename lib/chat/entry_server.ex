defmodule Chat.EntryServer do
  use GenServer
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

    case :gen_tcp.listen(5000, options) do
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

    case command do
      {:REGISTER, name} ->
        case Registry.lookup(Registry.Users, name) do
          [{_, nil}] ->
            :gen_tcp.send(socket, "NOK taken\r\n\r\n")
            {:ok, nil}

          [] ->
            :gen_tcp.send(socket, "OK REGISTERED\r\n\r\n")
            Chat.UserSupervisor.add_user({name, socket})
            {:ok, :handled}
        end

      _ ->
        :gen_tcp.send(socket, "NOK unknown command\r\n\r\n")
    end
  end
end

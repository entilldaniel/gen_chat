defmodule Chat.Room do
  use GenServer
  require Logger
  
  defstruct ~w[name users]a

  @impl true
  def init(name) do
    state = %__MODULE__{name: name, users: []}
    {:ok, state}
  end

  def send_message(pid, envelope), do: GenServer.cast(pid, {:message, envelope})

  @impl true
  def handle_cast({:join, handle}, state) do
    Logger.info("Failing")
    state = %{state | :users => [handle|state.users]}
    {:noreply, state}
  end

  
  

  
end

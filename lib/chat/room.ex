defmodule Chat.Room do
  use GenServer

  defstruct [users: []]

  @impl true
  def init(init \\ %__MODULE__{}) do
    {:ok, init}
  end

  
  

  
end

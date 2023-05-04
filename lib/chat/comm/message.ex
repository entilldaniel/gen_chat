defmodule Chat.Comm.Message do
  require Logger

  def send(socket, message) do
    :gen_tcp.send(socket, "#{String.trim(message)}\n\n")
  end
end

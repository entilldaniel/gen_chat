defmodule GenChat.Comm.DataProxy do
  @callback send(channel :: term, message :: term) :: {:ok, result :: term} | {:error, reason :: term}
  @callback receive(channel :: term) :: {:ok, result :: term} | {:error, reason :: term}
end

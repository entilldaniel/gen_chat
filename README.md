# Gen Chat

This is a simple chat server that I'm implementing in my journey to learn elixir. 

The protocol is very simple there are a few commands so far that you can see in `lib/command/user_command.ex`

## Commands
### PUBLIC
Send a public message in a room
### PRIVATE
Send a private message to a handle
### LIST*ROOMS
List the available rooms
### ENTER
Enter a room
### LIST*USERS
List the users currently in a room
### CREATE
Create a room
### EXIT
Leave a room
### REGISTER
Register your handle
### WHOAMI
Display your handle and the rooms you're currently in.
### DISCONNECT
Not implemented


# Installation #


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/chat>.


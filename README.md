# Gen Chat

This is a simple chat library that I'm working on for fun in order to learn elixir. 

The protocol is relatively simple, there are a few commands so far that you can see in `lib/command/user_command.ex`

## Commands
### `PUBLIC`
Send a public message in a room
### `PRIVATE`
Send a private message to a handle
### `LIST_ROOMS`
List the available rooms
### `ENTER`
Enter a room
### `LIST_USERS`
List the users currently in a room
### `CREATE`
Create a room
### `EXIT`
Leave a room
### `REGISTER`
Register your handle
### `WHOAMI`
Display your handle and the rooms you're currently in.
### `DISCONNECT`
Not implemented

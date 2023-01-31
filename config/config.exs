import Config

config :chat,
  port: 5000,
  preconfigured_rooms: ["lobby", "dungeon", "attic"]


import_config "#{config_env()}.exs"

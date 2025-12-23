local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_5",
  music = "items/ocarina/song/5_lorule",
	type = "teleportation",
  destination_map = "out/b5",
	destination = "from_flute",
	duration = 18000,
	demo_duraiton = 3000,
	dialogue = "items.ocarina.teleport.song_5_lorule",
}
config:create(item, properties)
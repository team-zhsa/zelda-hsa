local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_14",
  music = "items/ocarina/song/14_storms",
	type = "teleportation",
  destination_map = "out/a3",
	destination = "from_flute",
	duration = 4000,
	demo_duration = 4000,
	dialogue = "items.ocarina.teleport.song_14_storms",
}
config:create(item, properties)


local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_13",
  music = "items/ocarina/song/13_light",
	type = "teleportation",
  destination_map = "out/g4",
	destination = "from_flute",
	duration = 16000,
	dialogue = "items.ocarina.teleport.song_13_light",
}
config:create(item, properties)


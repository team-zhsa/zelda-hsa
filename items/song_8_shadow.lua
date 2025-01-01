local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_8",
  music = "items/ocarina/song/8_shadow",
	type = "teleportation",
  destination_map = "out/a1",
	destination = "from_flute",
	duration = 20000,
	dialogue = "items.ocarina.teleport.song_8_shadow",
}
config:create(item, properties)


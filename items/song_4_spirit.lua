local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_4",
  music = "items/ocarina/song/4_spirit",
	type = "teleportation",
  destination_map = "out/b5",
	destination = "from_flute",
	duration = 22000,
	demo_duration = 6000,
	dialogue = "items.ocarina.teleport.song_4_spirit",
}
config:create(item, properties)

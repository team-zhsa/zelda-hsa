local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_2",
  music = "items/ocarina/song/2_fire",
	type = "teleportation",
  destination_map = "out/b1",
	destination = "from_flute",
	duration = 18000,
	demo_duration = 4000,
	dialogue = "items.ocarina.teleport.song_2_fire",
}
config:create(item, properties)
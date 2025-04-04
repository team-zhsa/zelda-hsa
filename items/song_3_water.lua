local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_3",
  music = "items/ocarina/song/3_water",
	type = "teleportation",
  destination_map = "out/a2",
	destination = "from_dungeon",
	duration = 17000,
	dialogue = "items.ocarina.teleport.song_3_water",
}
config:create(item, properties)

local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_2",
  music = "items/ocarina/song/2_fire",
  destination_map = "out/b1",
	destination = "from_flute",
	duration = 18000,
	dialogue = "items.ocarina.teleport.song_2_forest",
}
config:create(item, properties)
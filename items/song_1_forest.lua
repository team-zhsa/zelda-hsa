local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_1",
  music = "items/ocarina/song/1_forest",
  destination_map = "out/b4",
	destination = "from_flute",
	duration = 15000,
	dialogue = "items.ocarina.teleport.song_1_forest",
}
config:create(item, properties)
local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_12",
  music = "items/ocarina/song/12_secret",
  destination_map = "out/k1",
	destination = "from_north_hut",
	duration = 3000,
	dialogue = "items.ocarina.teleport.song_12_secret",
}
config:create(item, properties)


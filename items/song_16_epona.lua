local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_16",
  music = "items/ocarina/song/16_epona",
	type = "skip_dialogue",
	effect = function()
		item:song_effect()
	end,
	duration = 7000,
}

function item:song_effect()
	print("TODO No Epona")
end

config:create(item, properties)
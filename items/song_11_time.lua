local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_11",
  music = "items/ocarina/song/11_time",
	type = "skip_dialogue",
	effect = function()
		item:song_effect()
	end,
	duration = 10000,
}

function item:song_effect()
	print("TODO Song of Time effect")
end

config:create(item, properties)
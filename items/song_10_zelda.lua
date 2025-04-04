local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_10",
  music = "items/ocarina/song/10_zelda",
	type = "skip_dialogue",
	effect = function()
		item:song_effect()
	end,
	duration = 9000,
}

function item:song_effect()
	print("TODO Zelda")
end

config:create(item, properties)
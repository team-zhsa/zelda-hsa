local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_7",
  music = "items/ocarina/song/17_lanayru",
	type = "skip_dialogue",
	effect = function()
		item:song_effect()
	end,
	duration = 9000,
}

function item:song_effect()
	print("TODO Lanayru")
end

config:create(item, properties)
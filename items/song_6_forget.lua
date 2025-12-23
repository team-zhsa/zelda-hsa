local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_6",
  music = "items/ocarina/song/6_epona",
	type = "skip_dialogue",
	effect = function()
		item:song_effect()
	end,
	duration = 7000,
	demo_duration = 5000,
}

function item:song_effect()
	print("TODO No Epona")
end

config:create(item, properties)
local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_9",
  music = "items/ocarina/song/9_healing",
	type = "skip_dialogue",
	effect = function()
		item:song_effect()
	end,
	duration = 9000,
}

function item:song_effect()
	print("TODO Healing")
end

config:create(item, properties)
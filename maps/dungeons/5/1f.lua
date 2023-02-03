local map= ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager.lua")

function map:on_started()
	separator_manager:manage_map(map)
end
-- Lua script of map dungeons/10/1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- Variables:

local map = ...
local game = map:get_game()
local separator_manager = require("scripts/maps/separator_manager.lua")

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	separator_manager:manage_map(map)
	key_yellow:set_enabled(false)
end

function map:on_opening_transition_finished()

end

-- Lua script of item world_map.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()

-- Event called when all items have been created.
function item:on_created()
	self:set_savegame_variable("possession_world_map")
	item:set_sound_when_brandished("items/get_major_item")
end

function item:on_obtained()
  game:set_step_done("world_map_obtained")
end

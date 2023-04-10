-- Lua script of map inside/caves/hylia_lake/hylia_to_kakarico.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local separator_manager = require("scripts/maps/separator_manager.lua")
require("scripts/maps/light_manager")

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
--	separator_manager:manage_map(map)

	map:set_light(0)
  -- You can initialise the movement and sprites of various
  -- map entities here.
end)

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
map:register_event("on_opening_transition_finished", function()

end)

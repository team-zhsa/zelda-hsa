-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
local audio_manager = require("scripts/audio_manager")
local fog_manager = require("scripts/maps/fog_manager")
map:register_event("on_started", function()
	map:set_digging_allowed(true)
  game:show_map_name("zora_forest")
	fog_manager:set_overlay(map, "forest_fog")
end)
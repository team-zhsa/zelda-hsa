-- Lua script of map out/l9.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
	game:show_map_name("finallis_island")
  -- You can initialize the movement and sprites of various
	map:set_digging_allowed(true)
end)

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()
  audio_manager:play_sound("common/secret_discover_minor")
end

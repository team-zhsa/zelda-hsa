-- Lua script of map misc/ending.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local end_credits = require("scripts/menus/credits")
local audio_manager = require("scripts/audio_manager")

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	game:set_hud_enabled(false)
	game:set_pause_allowed(false)	
	
	sol.menu.start(game, end_credits)
	audio_manager:play_music("cutscenes/end_credits")
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()
	map:get_hero():freeze()
	map:get_hero():set_visible(false)
end

function end_credits:on_finished()
	game:set_hud_enabled(true)
	game:set_pause_allowed(true)
	map:get_hero():unfreeze()
	map:get_hero():set_visible(true)
end



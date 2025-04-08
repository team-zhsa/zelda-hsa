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
	hero:freeze()
	--map:get_hero():set_visible(false)
	sol.timer.start(map, 5000, function()
		local movement = sol.movement.create("straight")
		movement:set_speed(32)
		movement:set_angle(math.pi / 2)
		movement:start(map:get_camera())
		sol.timer.start(map, 500, function()
			map:start_credits()
		end)
	end)

end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:start_credits()
	sol.menu.start(game, end_credits)
	if game:get_value("death_count") == 0 or game:get_value("death_count") == nil then
		sol.audio.play_music("cutscenes/end_credits_alttp", function()
			sol.audio.stop_music()
		end)
	else
		sol.audio.play_music("cutscenes/end_credits", function()
			sol.audio.stop_music()
		end)
	end
end

function end_credits:on_finished()
	game:set_hud_enabled(false)
	game:set_pause_allowed(false)
	map:get_hero():unfreeze()
	map:get_hero():set_visible(false)
end



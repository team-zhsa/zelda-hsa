-- This script adds to maps some functions that allow you to change the music between day and night.
--
-- Maps will have the following new functions:
-- field_music_manager:start_field_music().
--
-- Usage:
--
-- local field_music_manager = require("scripts/maps/field_music_manager")
--
-- map:register_event("on_draw", function(map)

	-- Music
	-- --field_music_manager:init(map)

--end)

local field_music_manager = {}
local audio_manager = require("scripts/audio_manager")
local map_meta = sol.main.get_metatable("map")
require("scripts/multi_events")

map_meta:register_event("on_started", function(map)
  local game = map:get_game()
	if map:get_id() == "out/a1" or "out/a6"
	or "out/b2" or "out/b6"
	or "out/c2" or "out/c3" or "out/c6"
	or "out/d2" or "out/d3" or "out/d4" or "out/d5" or "out/d6"
	or "out/e2" or "out/e4" or "out/e5"
	or "out/f2" or "out/f3" or "out/f5" or "out/f6"
	or "out/g2" or "out/g3" or "out/g4" or "out/g5" or "out/g6" or "out/g7"
	or "out/h2" or "out/h3" or "out/h4" or "out/h5" or "out/h6"
	or "out/i5" or "out/i6"
	or "out/j4" or "out/k3" or "out/k4" then
		if not game:is_step_done("dungeon_1_started") then
			audio_manager:play_music("outside/hyrule_field_beginning")
		elseif game:is_step_last("priest_kidnapped") then
			audio_manager:play_music("cutscenes/cutscene_danger")
		else
			if game:get_value("time_of_day") == "day" or game:get_value("time_of_day") == nil then
				audio_manager:play_music("outside/hyrule_field_day")
			elseif game:get_value("time_of_day") == "night" then
				audio_manager:play_music("outside/hyrule_field_night")
			end
		end
	end
end)

return field_music_manager
--[[



function field_music_manager:init(map)
	local game = map:get_game()
	function field_music_manager:start_field_music()

	end
	field_music_manager:start_field_music()
end

--]]
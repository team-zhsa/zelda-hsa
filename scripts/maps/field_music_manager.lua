-- This script adds to maps some functions that allow you to change the music between day and night.

local field_music_manager = {}
local audio_manager = require("scripts/audio_manager")
local map_meta = sol.main.get_metatable("map")
require("scripts/multi_events")

local field_id = {"out/a1", "out/a6",
"out/b2", "out/b6",
"out/c2", "out/c3", "out/c6",
"out/d2", "out/d3", "out/d4", "out/d5", "out/d6",
"out/e2", "out/e3", "out/e4", "out/e5",
"out/f2", "out/f3", "out/f5", "out/f6",
"out/g2", "out/g3", "out/g4", "out/g5", "out/g6", "out/g7",
"out/h2", "out/h3", "out/h4", "out/h5", "out/h6",
"out/i5", "out/i6",
"out/j4", "out/k3", "out/k4"}

local function map_is_field(id)
	for index = 1, #field_id do
		if field_id[index] == id then
			return true
		end
	end
end

map_meta:register_event("on_started", function(map)
  local game = map:get_game()
	if map_is_field(map:get_id()) then
		if not game:is_step_done("dungeon_1_started") then
			if game:get_value("time_of_day") == "day" or game:get_value("time_of_day") == nil then
				audio_manager:play_music("outside/hyrule_field_intro_day")
			elseif game:get_value("time_of_day") == "night" then
				audio_manager:play_music("outside/hyrule_field_intro_night")
			end
		elseif game:is_step_last("priest_kidnapped") then
			audio_manager:play_music("cutscenes/cutscene_danger")
		elseif (game:is_step_done("dungeon_1_started") and not game:is_step_done("priest_kidnapped"))
					or	game:is_step_done("agahnim_met") then
			if game:get_value("time_of_day") == "day" or game:get_value("time_of_day") == nil then
				audio_manager:play_music("outside/hyrule_field_day")
			elseif game:get_value("time_of_day") == "night" then
				audio_manager:play_music("outside/hyrule_field_night")
			end
		end
	else audio_manager:play_music(map:get_music())
	end
end)

return field_music_manager
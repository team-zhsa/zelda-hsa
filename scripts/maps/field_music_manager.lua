-- This script adds to maps some functions that allow you to change the music between day and night.

local field_music_manager = {}
local audio_manager = require("scripts/audio_manager")
local map_meta = sol.main.get_metatable("map")
require("scripts/multi_events")

local north_field_id = {
"out/a1",
"out/b2",
"out/c2", "out/c3",
"out/d2", "out/d3",
"out/e2", "out/e3",
"out/f2", "out/f3",
"out/g2", "out/g3", "out/g4",
"out/h2", "out/h3",}

local south_field_id = {
"out/a6",
"out/b6",
"out/c6",
"out/d4", "out/d5", "out/d6",
"out/e4", "out/e5", "out/e6",
"out/f5", "out/f6",
"out/g5", "out/g6", "out/g7",
"out/h4", "out/h5", "out/h6",
"out/i5", "out/i6",
"out/j4", "out/k3", "out/k4"}

local function map_is_north_field(id)
	for index = 1, #north_field_id do
		if north_field_id[index] == id then
			return true
		end
	end
end

local function map_is_south_field(id)
	for index = 1, #south_field_id do
		if south_field_id[index] == id then
			return true
		end
	end
end

function field_music_manager:play_day(map, game)
	if map_is_north_field(map:get_id()) then

		if not game:is_step_done("dungeon_1_started") then -- Intro music
			audio_manager:play_music_fade(map, "outside/north_field_intro_day")
		elseif game:is_step_last("priest_kidnapped") then
			audio_manager:play_music_fade(map, "cutscenes/cutscene_danger")
		elseif (game:is_step_done("dungeon_1_started") and not game:is_step_done("priest_kidnapped"))
			or	game:is_step_done("agahnim_met") then -- Normal music
			audio_manager:play_music_fade(map, "outside/north_field_day")
		end
		
	elseif map_is_south_field(map:get_id()) then

		if not game:is_step_done("dungeon_1_started") then -- Intro music
				audio_manager:play_music_fade(map, "outside/south_field_intro_day")
		elseif game:is_step_last("priest_kidnapped") then
			audio_manager:play_music_fade(map, "cutscenes/cutscene_danger")
		elseif (game:is_step_done("dungeon_1_started") and not game:is_step_done("priest_kidnapped"))
					or	game:is_step_done("agahnim_met") then -- Normal music
				audio_manager:play_music_fade(map, "outside/south_field_day")
		end

	else audio_manager:play_music_fade(map, map:get_music())
	
	end
end

function field_music_manager:play_night(map, game)
	if map_is_north_field(map:get_id()) then

		if not game:is_step_done("dungeon_1_started") then -- Intro music
			audio_manager:play_music_fade(map, "outside/north_field_intro_night")
		elseif game:is_step_last("priest_kidnapped") then
			audio_manager:play_music_fade(map, "cutscenes/cutscene_danger")
		elseif (game:is_step_done("dungeon_1_started") and not game:is_step_done("priest_kidnapped"))
			or	game:is_step_done("agahnim_met") then -- Normal music
			audio_manager:play_music_fade(map, "outside/north_field_night")
		end
		
	elseif map_is_south_field(map:get_id()) then

		if not game:is_step_done("dungeon_1_started") then -- Intro music
				audio_manager:play_music_fade(map, "outside/south_field_night")
		elseif game:is_step_last("priest_kidnapped") then
			audio_manager:play_music_fade(map, "cutscenes/cutscene_danger")
		elseif (game:is_step_done("dungeon_1_started") and not game:is_step_done("priest_kidnapped"))
					or	game:is_step_done("agahnim_met") then -- Normal music
				audio_manager:play_music_fade(map, "outside/south_field_night")
		end

	else audio_manager:play_music_fade(map, map:get_music())
	
	end
end

function field_music_manager:play_music(map, game)
	if game:get_value("time_of_day") == "day" or game:get_value("time_of_day") == nil then
		field_music_manager:play_day(map, game)
	elseif game:get_value("time_of_day") == "night" then
		field_music_manager:play_night(map, game)
	end

	sol.timer.start(game, 10000, function()
		field_music_manager:play_music(map, game)
		return true
	end)

end

map_meta:register_event("on_started", function(map)
  local game = map:get_game()
	field_music_manager:play_music(map, game)
end)

return field_music_manager
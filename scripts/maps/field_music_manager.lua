-- This script adds to maps some functions that allow you to change the music between day and night.

local field_music_manager = {}
local audio_manager = require("scripts/audio_manager")
local map_meta = sol.main.get_metatable("map")
local playing_time = ""
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

map_meta:register_event("on_started", function(map)
  local game = map:get_game()
	if map_is_south_field(map:get_id()) or map_is_north_field(map:get_id()) then
		field_music_manager:check_time(map)
		field_music_manager:play_music(map, game, playing_time)
		sol.timer.start(map, 1000, function()
			field_music_manager:check_time(map)
			return true
		end)
	end
end)

function field_music_manager:check_time(map)
	local game = sol.main.get_game()
	local current_time = game:get_value("time_of_day")
	if playing_time ~= current_time then
		playing_time = current_time
		
		field_music_manager:play_music(map, playing_time)
		print("check_time new playing "..playing_time)
	end

end

function field_music_manager:play_music(map, playing_time)
		if playing_time == "night" then
			field_music_manager:play_night(map)
		elseif playing_time == "day" or "dawn" or "sunset" or "twilight" then
			field_music_manager:play_day(map)
		end

end

function field_music_manager:play_day(map)
	local game = sol.main.get_game()
	if map_is_north_field(map:get_id()) then
		if not game:is_step_done("dungeon_1_started") then -- Intro music
			audio_manager:play_music("outside/north_field_intro_day")
		elseif game:is_step_last("priest_kidnapped") then
			audio_manager:play_music("cutscenes/cutscene_danger")
		elseif (game:is_step_done("dungeon_1_started") and not game:is_step_done("priest_kidnapped"))
			or	game:is_step_done("agahnim_met") then -- Normal music
			audio_manager:play_music("outside/north_field_day")
		end
		
	elseif map_is_south_field(map:get_id()) then
		if not game:is_step_done("dungeon_1_started") then -- Intro music
				audio_manager:play_music("outside/south_field_intro_day")
		elseif game:is_step_last("priest_kidnapped") then
			audio_manager:play_music("cutscenes/cutscene_danger")
		elseif (game:is_step_done("dungeon_1_started") and not game:is_step_done("priest_kidnapped"))
					or	game:is_step_done("agahnim_met") then -- Normal music
				audio_manager:play_music("outside/south_field_day")
		end
	end

end

function field_music_manager:play_night(map)
	local game = sol.main.get_game()
	if map_is_north_field(map:get_id()) then
		if not game:is_step_done("dungeon_1_started") then -- Intro music
			audio_manager:play_music("outside/north_field_intro_night")
		elseif game:is_step_last("priest_kidnapped") then
			audio_manager:play_music("cutscenes/cutscene_danger")
		elseif (game:is_step_done("dungeon_1_started") and not game:is_step_done("priest_kidnapped"))
			or	game:is_step_done("agahnim_met") then -- Normal music
			audio_manager:play_music("outside/north_field_night")
		end
		
	elseif map_is_south_field(map:get_id()) then
		if not game:is_step_done("dungeon_1_started") then -- Intro music
				audio_manager:play_music("outside/south_field_night")
		elseif game:is_step_last("priest_kidnapped") then
			audio_manager:play_music("cutscenes/cutscene_danger")
		elseif (game:is_step_done("dungeon_1_started") and not game:is_step_done("priest_kidnapped"))
					or	game:is_step_done("agahnim_met") then -- Normal music
				audio_manager:play_music("outside/south_field_night")
		end
	end

end

return field_music_manager
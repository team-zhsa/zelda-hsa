-- Lua script of map out/f5.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local num_dialogue = 0
local white_surface = sol.surface.create(320, 256)
white_surface:fill_color{255, 255, 255}

function map:on_draw(dst_surface)
	if game:is_step_last("zelda_kidnapped") then
		white_surface:draw(dst_surface)
	end
end

map:register_event("on_started", function(map, destination)
	game:show_map_name("castle_town")
	map:set_digging_allowed(true)
	npc_impa:set_enabled(false)
	if game:get_time_of_day() == "day" then
		if game:is_step_done("sahasrahla_lost_woods_map") then
			day_town_gate:set_enabled(false)
		else day_town_gate:set_enabled(true)
		end
	else day_town_gate:set_enabled(true)
	end

	for npc in map:get_entities("npc_soldier_") do
		if game:is_step_done("lamp_obtained") then
			npc:set_enabled(false)
		else npc:set_enabled(true)
		end
	end

	if game:is_step_last("game_started") then
		npc_impa:set_enabled(true)
	else npc_impa:set_enabled(false)
	end

	for switch in map:get_entities("switch_castle_barrier_") do
		if not game:is_step_last("zelda_kidnapped") then
			switch:set_enabled(false)
		else switch:set_visible(false)
		end
	end

	if not game:is_step_last("zelda_kidnapped") then
		entity_castle_barrier:set_enabled(false)
	end
	white_surface:set_opacity(0)

	if destination == from_castle_2 and game:is_step_last("zelda_kidnapped") then
		sol.audio.play_music("cutscenes/castle_sealed")
	end

end)

npc_quay:register_event("on_interaction", function()
--  game:start_quest("quay", true)
end)

-- Hyrule Castle barrier
for switch in map:get_entities("switch_castle_barrier_") do
	switch:register_event("on_activated", function()
		switch_castle_barrier_1:remove()
		switch_castle_barrier_2:remove()
		switch_castle_barrier_3:remove()
		map:start_castle_seal_cutscene()
	end)
end

function map:start_castle_seal_cutscene()
	map:set_cinematic_mode(true)
	sol.timer.start(map, 1000, function()
		white_surface:fade_in()
		sol.audio.play_sound("items/farore_wind/cast")
		sol.timer.start(map, 200, function()
			entity_castle_barrier:get_sprite():fade_out(400) -- set_enabled(false)
			white_surface:fade_out()
			map:set_cinematic_mode(false)
			audio_manager:play_music_fade(map, map:get_music())
		end)
	end)
end

-- Bridge soldiers
for npc in map:get_entities("npc_soldier_") do
	npc:register_event("on_interaction", function()
		if num_dialogue == 0 then
			game:start_dialog("maps.out.castle_town.soldiers.no_lamp")
			num_dialogue = 1
		elseif num_dialogue == 1 then
			game:start_dialog("maps.out.castle_town.soldiers.tip_item")
			num_dialogue = 2
		elseif num_dialogue == 2 then
			game:start_dialog("maps.out.castle_town.soldiers.tip_pause")
			num_dialogue = 3
		elseif num_dialogue == 3 then
			game:start_dialog("maps.out.castle_town.soldiers.tip_speak")
			num_dialogue = 0
		end
	end)
end

-- Impa cutscene
function map:start_impa_cutscene()
	npc_impa:set_enabled(true)
	map:set_cinematic_mode(true)
	hero:set_direction(1)
	audio_manager:play_music("cutscenes/cutscene_zelda")
	local impa_movement_to_position = sol.movement.create("target")
	impa_movement_to_position:set_target(impa_position)
	impa_movement_to_position:set_ignore_obstacles(true)
	impa_movement_to_position:set_ignore_suspend(true)
	impa_movement_to_position:set_speed(100)
	impa_movement_to_position:start(npc_impa, function()
		game:start_dialog("maps.out.castle_town.impa.intro_1", game:get_player_name(), function()
			ocarina_dialogue()
		end)
	end)

end

sensor_ocarina_cutscene:register_event("on_activated", function()
	if game:is_step_last("game_started") then
		map:start_impa_cutscene()

	end
end)

function ocarina_dialogue()
	game:start_dialog("maps.out.castle_town.impa.intro_2", game:get_player_name(), function(answer)
		if answer == 1 then
			ocarina_dialogue()
		elseif answer == 2 then
			game:start_dialog("maps.out.castle_town.impa.song_learnt", function()
				hero:start_treasure("song_10_zelda", 1,nil, function()
					game:set_step_done("ocarina_obtained")
					local impa_movement_leave = sol.movement.create("target")
					impa_movement_leave:set_target(640, 208)
					impa_movement_leave:set_ignore_obstacles(true)
					impa_movement_leave:set_ignore_suspend(true)
					impa_movement_leave:set_speed(100)
					impa_movement_leave:start(npc_impa, function()
						map:set_cinematic_mode(false, options)
						npc_impa:set_enabled(false)
						audio_manager:play_music_fade(map, map:get_music())
						end)
				end)
			end)
		end
	end)
end

-- Camera tour cutscene

-- Door events
open_house_door_castle_sensor:register_event("on_activated", function()
	if hero:get_direction() == 1 and door_castle_1:is_enabled() and door_castle_2:is_enabled() then
		door_castle_1:set_enabled(false)
		door_castle_2:set_enabled(false)
		sol.audio.play_sound("door_open")
	end
end)

open_house_door_castle_left_sensor:register_event("on_activated", function()
	if hero:get_direction() == 1 and door_castle_left_1:is_enabled() and door_castle_left_2:is_enabled() then
		door_castle_left_1:set_enabled(false)
		door_castle_left_2:set_enabled(false)
		sol.audio.play_sound("door_open")
	end
end)

open_house_door_castle_right_sensor:register_event("on_activated", function()
	if hero:get_direction() == 1 and door_castle_right_1:is_enabled() and door_castle_right_2:is_enabled() then
		door_castle_right_1:set_enabled(false)
		door_castle_right_2:set_enabled(false)
		sol.audio.play_sound("door_open")
	end
end)

open_house_door_vase_sensor:register_event("on_activated", function()
	if hero:get_direction() == 1 and door_vase_1:is_enabled() and door_vase_2:is_enabled() then
		door_vase_1:set_enabled(false)
		door_vase_2:set_enabled(false)
		sol.audio.play_sound("door_open")
	end
end)

open_house_door_bank_sensor:register_event("on_activated", function()
	if hero:get_direction() == 1 and door_bank_1:is_enabled() and door_bank_2:is_enabled() then
		door_bank_1:set_enabled(false)
		door_bank_2:set_enabled(false)
		sol.audio.play_sound("door_open")
	end
end)

-- NPC events
for npc in map:get_entities("npc_laundry_") do
	npc:register_event("on_interaction", function()
		if game:is_step_last("ocarina_obtained") then
			game:start_dialog("maps.out.castle_town.laundry_pool.no_magic_bar")
		elseif game:is_step_last("agahnim_met") then
			game:start_dialog("maps.out.castle_town.laundry_pool.soldiers")
		else game:start_dialog("maps.out.castle_town.laundry_pool.busy")
		end
	end)
end

npc_drunk_man:register_event("on_interaction", function()
	if game:is_step_last("ocarina_obtained") then
		game:start_dialog("maps.out.castle_town.drunk_man.no_lamp")
	elseif game:is_step_last("lamp_obtained") then
		game:start_dialog("maps.out.castle_town.drunk_man.no_sword")
	else game:start_dialog("maps.out.castle_town.drunk_man.sleeping")
	end
end)

npc_fisher:register_event("on_interaction", function()
	if game:is_step_last("ocarina_obtained") then
		game:start_dialog("maps.out.castle_town.fisher.welcome_no_lamp")
	elseif game:is_step_last("lamp_obtained") then
		game:start_dialog("maps.out.castle_town.fisher.welcome_no_sword")
	elseif not game:is_step_last("dungeon_3_completed") then
		game:start_dialog("maps.out.castle_town.fisher.welcome_no_fish")
	else game:start_dialog("maps.out.castle_town.fisher.welcome")
	end
end)

--On butter quest npc interaction
function npc_4:on_interaction()
--Get if player have begun this quest
	if game:get_value("quest_butter", 0) then
		game:start_dialog("quest.butter.need_butter", function(answer)
			if answer == 2 then
				game:start_dialog("quest.butter.yes")
				game:set_value("quest_butter", 1)
			else
				game:start_dialog("quest.butter.no")
			end
		end)
	end
end 
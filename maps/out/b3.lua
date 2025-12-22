-- Lua script of map out/b3.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local camera = map:get_camera()
local outside_kakarico_playing_maze
local outside_kakarico_won_maze
local num_dialogue = 0
local timer_manager = require("scripts/maps/timer_manager")

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
	game:show_map_name("kakarico_village")
	outside_kakarico_playing_maze = false
	outside_kakarico_won_maze = false
	map:set_digging_allowed(true)
	if game:is_step_done("lost_woods_mapper_met") then
		for npc in map:get_entities("npc_soldier_") do
			npc:set_enabled(false)
		end
	end
end)

for npc in map:get_entities("npc_soldier_") do
	npc:register_event("on_interaction", function()
		if num_dialogue == 0 then
			if game:get_time_of_day() == "dawn" or game:get_time_of_day() == "day" or game:get_time_of_day() == "sunset" then
				game:start_dialog("maps.out.kakarico_village.soldiers.soldiers_day")
				num_dialogue = 1
			elseif game:get_time_of_day() == "night" or game:get_time_of_day() == "twillight" then
				game:start_dialog("maps.out.kakarico_village.soldiers.soldiers_night")
				num_dialogue = 1
			end
		elseif num_dialogue == 1 then
			game:start_dialog("maps.out.kakarico_village.soldiers.tip_map")
			num_dialogue = 2
		elseif num_dialogue == 2 then
			game:start_dialog("maps.out.kakarico_village.soldiers.tip_shop")
			num_dialogue = 3
		elseif num_dialogue == 3 then
			game:start_dialog("maps.out.kakarico_village.soldiers.tip_speak")
			num_dialogue = 0
		end
	end)
end

function map:on_finished()
	outside_kakarico_playing_maze = false
	outside_kakarico_won_maze = false
end

function grandma:on_interaction()
	--if game:is_step_done("ganon_threat") then
		game:start_dialog("maps.out.kakarico_village.grandma_1")
	--end
end

-- Maze Game
function npc_maze_game:on_interaction()
	if not outside_kakarico_playing_maze
	and not outside_kakarico_won_maze then --not playing
		game:start_dialog("maps.out.kakarico_village.maze.maze_welcome", function(answer)
			if answer == 1 then
				if game:get_money() >= 20 then
					game:remove_money(20)
					switch_maze_game:set_activated(false)
					npc_maze_game:set_traversable(true)
					sol.audio.play_music("inside/minigame_alttp")
					game:start_dialog("maps.out.kakarico_village.maze.maze_yes")
					outside_kakarico_playing_maze = true
					timer_manager:start_timer(map, 15000, "countdown", function() --Timer for 15 seconds
						--outside_kakarico_playing_maze = false
						if not switch_maze_game:is_activated() then
							game:start_dialog("maps.out.kakarico_village.maze.maze_loose")
							sol.audio.play_music("outside/kakarico")
							outside_kakarico_playing_maze = false
							outside_kakarico_won_maze = false
						end
					end)
				elseif game:get_money() < 20 then
					game:start_dialog("_shop.not_enough_money")
				end
			elseif answer == 2 then
				game:start_dialog("maps.out.kakarico_village.maze.maze_no")
			end
		end)
	elseif outside_kakarico_playing_maze
		and not outside_kakarico_won_maze then -- playing
		game:start_dialog("maps.out.kakarico_village.maze.maze_activate_switch")
	elseif outside_kakarico_playing_maze
		and outside_kakarico_won_maze
		and not game:get_value("outside_kakarico_maze_piece_of_heart", true) then -- piece of heart
		game:start_dialog("maps.out.kakarico_village.maze.maze_piece_of_heart", function()
			hero:start_treasure("piece_of_heart")
		end)
		game:set_value("outside_kakarico_maze_piece_of_heart", true)
		sol.audio.play_music("outside/kakarico")
		outside_kakarico_playing_maze = false
		outside_kakarico_won_maze = false
		hero:teleport("out/b3", "end_maze")
	elseif outside_kakarico_playing_maze and outside_kakarico_won_maze and game:get_value("outside_kakarico_maze_piece_of_heart", true) then
		game:start_dialog("maps.out.kakarico_village.maze.maze_rupee", function()
			hero:start_treasure("rupee", 4)
		end)
		outside_kakarico_playing_maze = false
		outside_kakarico_won_maze = false
		sol.audio.play_music("outside/kakarico")
		hero:teleport("out/b3", "end_maze")
	else
		game:start_dialog("maps.out.kakarico_village.maze.maze_loose")
	end
end

function switch_maze_game:on_activated()
	if outside_kakarico_playing_maze and not outside_kakarico_won_maze then
		sol.timer.stop_all(map)
		game:start_dialog("maps.out.kakarico_village.maze.maze_win", function()
			outside_kakarico_won_maze = true
			outside_kakarico_playing_maze = true
		end)
	elseif not outside_kakarico_playing_maze then
		sol.audio.play_sound("common/wrong")
		switch_maze_game:set_activated(false)
	end
end

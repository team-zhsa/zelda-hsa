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


-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	game:show_map_name("kakarico_village")
	outside_kakarico_playing_maze = false
	outside_kakarico_won_maze = false
	map:set_digging_allowed(true)
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
	if outside_kakarico_playing_maze == false and outside_kakarico_won_maze == false then --not playing
		game:start_dialog("maps.out.kakarico_village.maze_2", function(answer)
			if answer == 1 then
				if game:get_money() >= 20 then
					game:remove_money(20)
					switch_maze_game:set_activated(false)
					npc_maze_game:set_traversable(true)
					sol.audio.play_music("inside/minigame_alttp")
					game:start_dialog("maps.out.kakarico_village.maze_3_yes")
					outside_kakarico_playing_maze = true
					sol.timer.start(game, 15000, function() --Timer for 15 seconds
						--outside_kakarico_playing_maze = false
						if not switch_maze_game:is_activated() then
							game:start_dialog("maps.out.kakarico_village.maze_loose")
							sol.audio.play_music("outside/kakarico")
						end
					end)
					local num_calls = 0 --Timer for timer sound
					sol.timer.start(game, 1000, function()
			  		sol.audio.play_sound("danger")
			  		num_calls = num_calls + 1
			  		return num_calls < 15	
					end)
				elseif game:get_money() < 20 then
					game:start_dialog("_shop.not_enough_money")
				end
			elseif answer == 2 then
				game:start_dialog("maps.out.kakarico_village.maze_3_no")
			end
		end)
	elseif outside_kakarico_playing_maze == true and outside_kakarico_won_maze == false then -- playing
		game:start_dialog("maps.out.kakarico_village.maze_activate_switch")
	elseif outside_kakarico_playing_maze == true and outside_kakarico_won_maze == true and not game:get_value("outside_kakarico_maze_piece_of_heart", true) then -- piece of heart
		game:start_dialog("maps.out.kakarico_village.maze_piece_of_heart", function()
			hero:start_treasure("piece_of_heart")
		end)
		game:set_value("outside_kakarico_maze_piece_of_heart", true)
		sol.audio.play_music("outside/kakarico")
		outside_kakarico_playing_maze = false
		outside_kakarico_won_maze = false
		hero:teleport("out/b3", "end_maze")
	elseif outside_kakarico_playing_maze == true and outside_kakarico_won_maze == true and game:get_value("outside_kakarico_maze_piece_of_heart", true) then
		game:start_dialog("maps.out.kakarico_village.maze_rupee", function()
			hero:start_treasure("rupee", 4)
		end)
		outside_kakarico_playing_maze = false
		outside_kakarico_won_maze = false
		sol.audio.play_music("outside/kakarico")
		hero:teleport("out/b3", "end_maze")
	else
		game:start_dialog("maps.out.kakarico_village.maze_loose")
	end
end

function switch_maze_game:on_activated()
	if outside_kakarico_playing_maze == true and outside_kakarico_won_maze == false then
		sol.timer.stop_all(game)
		game:start_dialog("maps.out.kakarico_village.maze_win", function()
			outside_kakarico_won_maze = true
			outside_kakarico_playing_maze = true
		end)
	elseif outside_kakarico_playing_maze == false then
		sol.audio.play_sound("wrong")
		switch_maze_game:set_activated(false)
	end
end

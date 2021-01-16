local map = ...
local game = map:get_game()
local separator_manager = require("scripts/maps/separator_manager.lua")
local num_calls = 0

function welcome_sensor:on_activated()
  game:start_dialog("maps.dungeons.1.welcome")
end

function map:on_started()
	separator_manager:manage_map(map)
  door_28_e_top:set_enabled(false)
  boss_door:set_open(true)
	boss_cont:set_enabled(false)
end

function door_28_e_sensor:on_collision_explosion()
  door_28_e_top:set_enabled(true)
  door_28_e_tile:set_enabled(false)
  sol.audio.play_sound("common/secret_discover_minor")
end

function sensor_e_22_rsp:on_activated()
  hero:save_solid_ground()
end

function switch_door_23_n1:on_activated()
  door_23_n1:open(function()
		close_door()
	end)
end

function close_door()
	repeat
		sol.timer.start(map, 1000, function()
			sol.audio.play_sound("danger")
			local num_calls = num_calls + 1 
		end)
	until num_calls ~= 15
		door_23_n1:close()
end

-- BOSS
function boss_sensor:on_activated()
	map:close_doors("boss_door")
	map:close_doors("final_door")
	game:start_dialog("maps.dungeons.1.boss_welcome")
	sol.audio.play_music("boss/boss")
end

function boss:on_dead()
	boss_cont:set_enabled(true)
	sol.audio.play_music("none")
	map:open_doors("final_door")
	game:start_dialog("maps.dungeons.1.pendant", game:get_player_name(), function()
		hero:start_treasure("instrument_1")
	end)
end
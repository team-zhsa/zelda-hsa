-- Lua script of map dungeons/2/b1.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local separator_manager = require("scripts/maps/separator_manager.lua")
require("scripts/coroutine_helper")
local light_manager = require("scripts/maps/light_manager")
local credits = require("scripts/menus/credits")
local house_manager = require("scripts/maps/house_manager")

-- Event called at initialization time, as soon as this map is loaded.

function map:on_started()
	light_manager:init(map)
	separator_manager:manage_map(map)
	dynamic_29:set_enabled(false)
	map:open_doors("door_10_s")
	map:open_doors("door_10_w")
	map:set_light(1)
	small_key_13:set_enabled(false)
	if game:get_value("dungeon_2_1f_10_collapse_ground", true) then
		map:open_doors("door_9_w")
		map:open_doors("door_8_e")
	end
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

for npc in map:get_entities("magic_booth") do
	function magic_booth:on_interaction()
		if not game:get_value("dungeon_2_crossing_puzzle") then
			game:start_dialog("maps.dungeons.2.hint.arrows")
		elseif not game:get_value("dungeon_2_holes_puzzle") then
			game:start_dialog("maps.dungeons.2.hint.holes")
		elseif not game:get_value("dungeon_2_cyclop_puzzle") then
			game:start_dialog("maps.dungeons.2.hint.cyclop")
		end
	end
end

function sensor_cross_puzzle_1:on_activated()
	game:set_value("puzzle_cross_from_south", 1)
	wall_cross_puzzle_1:set_enabled(false)
	wall_cross_puzzle_4:set_enabled(false)
	sensor_cross_puzzle_4:set_enabled(false)
end

function sensor_cross_puzzle_3:on_activated()
	game:set_value("puzzle_cross_from_east", 1)
	wall_cross_puzzle_2:set_enabled(false)
	wall_cross_puzzle_4:set_enabled(false)
	sensor_cross_puzzle_2:set_enabled(false)
end

function sensor_cross_puzzle_2:on_activated()
	game:set_value("puzzle_cross_from_north", 1)
	wall_cross_puzzle_2:set_enabled(false)
	wall_cross_puzzle_3:set_enabled(false)
	sensor_cross_puzzle_4:set_enabled(false)
end

function sensor_cross_puzzle_4:on_activated()
	game:set_value("puzzle_cross_from_north", 1)
	wall_cross_puzzle_1:set_enabled(false)
	wall_cross_puzzle_3:set_enabled(false)
	sensor_cross_puzzle:set_enabled(false)
end

local function teleport_sensor(to_sensor, from_sensor)
  local hero_x, hero_y = hero:get_position()
  local to_sensor_x, to_sensor_y = to_sensor:get_position()
  local from_sensor_x, from_sensor_y = from_sensor:get_position()
 
  hero:set_position(hero_x - from_sensor_x + to_sensor_x, hero_y - from_sensor_y + to_sensor_y)
end
 
function sensor_corridor_from_13:on_activated()
  teleport_sensor(sensor_corridor_to_13, self)
end
 
function sensor_corridor_from_25:on_activated()
  teleport_sensor(sensor_corridor_to_25, self)
	sol.audio.play_sound("common/secret_discover_minor")
end

function sensor_30_dynamic:on_activated()
	dynamic_29:set_enabled(true)
end

function sensor_10_s_door:on_activated()
	map:close_doors("door_10_s")
	map:close_doors("door_10_w")
end

for enemy in map:get_entities("enemy_10_door") do
	function enemy:on_dead()
    if not map:has_entities("enemy_10_door") then
			map:open_doors("door_10_w")
    end
  end	
end

function switch_9_door:on_activated()
	map:open_doors("door_15_s")
end

function door_4_s:on_opened()
	dynamic__4_wall_s:set_enabled(false)
	dynamic__9_wall_n:set_enabled(false)
	game:set_value("dungeon_2_b1_door_4_s", true)
end

function sensor_8_door:on_activated()
	map:close_doors("door_8_e")
	map:close_doors("door_8_s")
end

for enemy in map:get_entities("auto_enemy") do
	function enemy:on_dead()
			if not map:has_entities("auto_enemy_12") and not map:has_entities("auto_enemy_13") and not map:has_entities("auto_enemy_14") and not map:has_entities("auto_enemy_15") then
				map:open_doors("door_8_s")
		end
	end
end

function sensor_13_door:on_activated()
	map:close_doors("door_13_n")
	map:close_doors("door_8_s")
	map:close_doors("door_13_w")
end

for enemy in map:get_entities("auto_enemy") do
	function enemy:on_dead()
		if not game:get_value("dungeon_2_small_key_2", true) then
			if not map:has_entities("auto_enemy_20") and not map:has_entities("auto_enemy_21") and not map:has_entities("auto_enemy_22") and not map:has_entities("auto_enemy_23") then
				small_key_13:set_enabled(true)
				sol.audio.play_sound("common/secret_discover_minor")
				game:set_value("dungeon_2_small_key_2", true)
				map:open_doors("door_13_n")
				map:open_doors("door_8_s")
				map:open_doors("door_8_e")
				map:open_doors("door_13_w")
				map:open_doors("door_12_e")
				sensor_8_door:set_enabled(false)
			end
		end
	end
end

function block_12:on_moved()
	if not game:get_value("dungeon_2_b1_12_stairs", true) then
		sol.audio.play_sound("common/secret_discover_minor")
		dynamic_12_stairs_wall:set_enabled(false)
		dynamic_12_stairs_top:set_enabled(false)
		game:set_value("dungeon_2_b1_12_stairs", true)
	end
end
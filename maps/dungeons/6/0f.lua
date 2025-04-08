-- Lua script of map dungeons/6/0f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local door_manager = require("scripts/maps/door_manager")
local enemy_manager = require("scripts/maps/enemy_manager")
local separator_manager = require("scripts/maps/separator_manager")
local switch_manager = require("scripts/maps/switch_manager")
local treasure_manager = require("scripts/maps/treasure_manager")
local flying_tile_manager = require("scripts/maps/flying_tile_manager")
local cannonball_manager = require("scripts/maps/cannonball_manager")
local water_level_manager = require("scripts/maps/water_level_manager")

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started(destination)
	map:set_doors_open("door_33_n", false)
	map:set_doors_open("door_33_e", false)
	if destination:get_name() == "from_outside" then
		water_level_manager:set_low_water_level(map)
	elseif destination:get_name() == "from_b1_2" then
		map:set_doors_open("door_33_n", true)
		map:set_doors_open("door_33_e", true)
	end
	water_level_manager:check_water_level(map)
	door_manager:open_when_switch_activated(map, "switch_26_door", "door_26_n_1")
	separator_manager:manage_map(map)
end


sensor_33_door_2:register_event("on_activated", function()
	map:close_doors("door_33_n")
end)

sensor_33_door_3:register_event("on_activated", function()
	map:close_doors("door_33_e")
end)

npc_18_hint:register_event("on_interaction", function()
	game:start_dialog("maps.dungeons.6.hint_1", game:get_player_name())
end)

handle_4_water_1:register_event("on_released", function()
	water_level_manager:switch_water_level(map)
end)

handle_4_water_2:register_event("on_released", function()
	water_level_manager:switch_water_level(map)
end)

handle_9_water:register_event("on_released", function()
	water_level_manager:switch_water_level(map)
end)

handle_18_water:register_event("on_released", function()
	water_level_manager:switch_water_level(map)
end)

handle_28_water:register_event("on_released", function()
	water_level_manager:switch_water_level(map)
end)

handle_17_water_1:register_event("on_released", function()
	for stream in map:get_entities("water_stream_17_1_") do
		local sprite = stream:get_sprite()
		if stream:get_direction() < 4 then
			stream:set_direction(6)
		elseif sprite:get_direction() >= 4 then
			stream:set_direction(2)
		end
	end
end)

handle_17_water_2:register_event("on_released", function()
	for stream in map:get_entities("water_stream_17_2_") do
		local sprite = stream:get_sprite()
		if sprite:get_direction() < 4 then
			stream:set_direction(4)
		elseif sprite:get_direction() >= 4 then
			stream:set_direction(0)
		end
	end
end)

handle_17_water_3:register_event("on_released", function()
	for stream in map:get_entities("water_stream_17_3_") do
		local sprite = stream:get_sprite()
		if stream:get_direction() < 4 then
			stream:set_direction(6)
		elseif sprite:get_direction() >= 4 then
			stream:set_direction(2)
		end
	end
end)

handle_17_water_4:register_event("on_released", function()
	for stream in map:get_entities("water_stream_17_2_") do
		local sprite = stream:get_sprite()
		if sprite:get_direction() < 4 then
			stream:set_direction(4)
		elseif sprite:get_direction() >= 4 then
			stream:set_direction(0)
		end
	end
end)


--[[ Water levels info:
static_water_X_N means that the Nth static water tile is enabled when the water level is at X (0 being the highest).
dynamic_water_A_B_K_R means that the Kth water tile (in water_tile index for raising/lowering the water) of the Rth room can be raised from level A to B.

Water levels:
0: water at -1 of 0F
1: water at -1 of B1
2: water at -1 of B2
3: water at -1 of B3
4: water at -1 of B4
5: water at -1 of B5

For handle base sprites :
Up arrow set to 1
Down arrow set to 2
Circle switch stream direction
Heart switch between water at the current floor and floor below

Triangle set to 3
Rupee set to 4
Wave set to 5--]]
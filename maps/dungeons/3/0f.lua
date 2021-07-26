-- Lua script of map dungeons/3/1f.
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

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
	separator_manager:manage_map(map)

-- Treasures
	treasure_manager:disappear_pickable(map, "pickable_35_small_key")
	treasure_manager:appear_pickable_when_enemies_dead(map, "enemy_35_", "pickable_35_small_key")

-- Doors
  map:set_doors_open("door_35_n", true)
  map:set_doors_open("door_9_s", false)
  map:set_doors_open("door_15_n", false)
  map:set_doors_open("door_16_s", false)
  map:set_doors_open("door_21_n", false)
	door_manager:open_when_enemies_dead(map, "enemy_35_", "door_35_n", sound)
	door_manager:open_when_switch_activated(map, "switch_15_door", "door_15_n")
	door_manager:open_when_switch_activated(map, "switch_16_door", "door_16_s")

  -- You can initialize the movement and sprites of various
  -- map entities here.
end)

sensor_35_door:register_event("on_activated", function()
	door_manager:close_if_enemies_not_dead(map, "enemy_35_", "door_35_n")
end)
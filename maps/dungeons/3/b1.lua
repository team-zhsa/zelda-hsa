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
  
-- Enemies
  for enemy in map:get_entities("enemy_1") do
    enemy:set_enabled(false)
  end

-- Treasures
	treasure_manager:disappear_pickable(map, "pickable_5_piece_of_heart")
	treasure_manager:appear_pickable_when_enemies_dead(map, "enemy_5_", "pickable_5_piece_of_heart")
  treasure_manager:disappear_chest(map, "chest_19_map")

-- Doors
  map:set_doors_open("door_5_w", true)
  map:set_doors_open("door_7_s", false)
	door_manager:open_when_enemies_dead(map, "enemy_5_", "door_5_w", sound)
	door_manager:open_when_switch_activated(map, "switch_20_door", "door_20_n")
  
  -- You can initialize the movement and sprites of various
  -- map entities here.
end)

sensor_5_door:register_event("on_activated", function()
	door_manager:close_if_enemies_not_dead(map, "enemy_5_", "door_5_w")
end)

pull_handle_1_1:register_event("on_released", function()
  for enemy in map:get_entities("enemy_1") do
    enemy:set_enabled(true)
  end
end)

pull_handle_1_2:register_event("on_released", function()
  map:open_doors("door_7_s")
end)

switch_19_chest:register_event("on_activated", function()
  treasure_manager:appear_chest(map, "chest_19_map", sound)
end)
-- Lua script of map dungeons/3/b2.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
require("scripts/multi_events")
local audio_manager = require("scripts/audio_manager")
local door_manager = require("scripts/maps/door_manager")
local enemy_manager = require("scripts/maps/enemy_manager")
local separator_manager = require("scripts/maps/separator_manager")
local switch_manager = require("scripts/maps/switch_manager")
local treasure_manager = require("scripts/maps/treasure_manager")
local flying_tile_manager = require("scripts/maps/flying_tile_manager")

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
	separator_manager:manage_map(map)
  
-- Treasures


-- Doors
	door_manager:open_when_enemies_dead(map, "enemy_2_", "door_2_e", sound)
	door_manager:open_when_enemies_dead(map, "enemy_2_", "door_2_s", sound)
  door_manager:open_when_enemies_dead(map, "enemy_16_", "door_16_n", sound)
	door_manager:open_when_enemies_dead(map, "enemy_16_", "door_16_s", sound)
  door_manager:open_when_flying_tiles_dead(map, "enemy_19_enemy", "door_19_e") -- Also opens "door_19_n" because of same savegame variable
  map:set_doors_open("door_2_e", true)
  map:set_doors_open("door_2_s", true)
  map:set_doors_open("door_16_n", true)
  map:set_doors_open("door_16_s", true)
  map:set_doors_open("door_19_n", true)
  map:set_doors_open("door_19_e", true)
  flying_tile_manager:reset(map, "enemy_19")
  for tile in map:get_entities("tile_5_floor") do
    tile:set_enabled(false)
  end
end)

sensor_2_door_1:register_event("on_activated", function()
	door_manager:close_if_enemies_not_dead(map, "enemy_2_", "door_2_e")
	door_manager:close_if_enemies_not_dead(map, "enemy_2_", "door_2_s")
end)

sensor_2_door_2:register_event("on_activated", function()
	door_manager:close_if_enemies_not_dead(map, "enemy_2_", "door_2_e")
	door_manager:close_if_enemies_not_dead(map, "enemy_2_", "door_2_s")
end)

sensor_16_door_1:register_event("on_activated", function()
	door_manager:close_if_enemies_not_dead(map, "enemy_16_", "door_16_n")
	door_manager:close_if_enemies_not_dead(map, "enemy_16_", "door_16_s")
end)

sensor_16_door_2:register_event("on_activated", function()
	door_manager:close_if_enemies_not_dead(map, "enemy_16_", "door_16_n")
	door_manager:close_if_enemies_not_dead(map, "enemy_16_", "door_16_s")
end)

sensor_19_flying_tile_init_1:register_event("on_activated", function()
	flying_tile_manager:init(map, "enemy_19")
end)

sensor_19_flying_tile_init_2:register_event("on_activated", function()
	flying_tile_manager:init(map, "enemy_19")
end)

sensor_19_flying_tile_launch_1:register_event("on_activated", function()
  if flying_tile_manager.is_launch == false then
      map:close_doors("door_19_n")
      map:close_doors("door_19_e")
    flying_tile_manager:launch(map, "enemy_19")
 end
end)

sensor_19_flying_tile_launch_2:register_event("on_activated", function()
  if flying_tile_manager.is_launch == false then
      map:close_doors("door_19_n")
      map:close_doors("door_19_e")
    flying_tile_manager:launch(map, "enemy_19")
 end
end)

switch_5_tile:register_event("on_activated", function()
  switch_5_tile:set_enabled(false)
  tile_5_floor_1:set_enabled(true)
  tile_5_floor_2:set_enabled(true)
  tile_5_floor_3:set_enabled(true)
  tile_5_floor_4:set_enabled(true)
  tile_5_floor_5:set_enabled(true)
  tile_5_floor_6:set_enabled(true)
  tile_5_floor_7:set_enabled(true)
  tile_5_floor_8:set_enabled(true)
  tile_5_floor_9:set_enabled(true)
  tile_5_floor_10:set_enabled(true)
  sol.timer.start(map, 7500, function()
    tile_5_floor_1:set_enabled(false)
    tile_5_floor_2:set_enabled(false)
    tile_5_floor_3:set_enabled(false)
    tile_5_floor_4:set_enabled(false)
    tile_5_floor_5:set_enabled(false)
    tile_5_floor_6:set_enabled(false)
    tile_5_floor_7:set_enabled(false)
    tile_5_floor_8:set_enabled(false)
    tile_5_floor_9:set_enabled(false)
    tile_5_floor_10:set_enabled(false)
  end)
end)
      
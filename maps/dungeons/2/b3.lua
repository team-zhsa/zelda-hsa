-- Lua script of map dungeons/2/b3.
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
local cannonball_manager = require("scripts/maps/cannonball_manager")
cannonball_manager:create_cannons(map, "cannon_")

map:register_event("on_started", function()
	separator_manager:manage_map(map)
	map:set_doors_open("door_13_s", true)
	map:set_doors_open("door_9_s", false)
  map:set_doors_open("door_10_w", true)
  map:set_doors_open("door_10_s", true)
	treasure_manager:disappear_pickable(map, "pickable_29_small_key")
	treasure_manager:disappear_pickable(map, "pickable_18_big_key")
	door_manager:open_when_flying_tiles_dead(map, "enemy_10_enemy", "door_10_w")
	door_manager:open_when_switch_activated(map, "switch_9_door", "door_9_s")
	treasure_manager:appear_pickable_when_enemies_dead(map, "enemy_29", "pickable_29_small_key")
	if game:get_value("dungeon_2_miniboss") ~= true then
		treasure_manager:appear_pickable_when_enemies_dead(map, "miniboss", "pickable_18_big_key")
		miniboss:set_enabled(false)
		door_manager:open_when_enemies_dead(map, "miniboss", "door_13_s", sound)
	end
  flying_tile_manager:reset(map, "enemy_10")
end)

if game:get_value("dungeon_2_miniboss") ~= true then
	miniboss_sensor:register_event("on_activated", function()
		audio_manager:play_music("boss/miniboss")
		miniboss:set_enabled(true)
		door_manager:close_if_enemies_not_dead(map, "miniboss", "door_13_s")
		miniboss_sensor:remove()
	end)

	miniboss:register_event("on_dead", function()
		audio_manager:play_music("dungeons/02_forest")
		treasure_manager:appear_pickable(map, "pickable_18_big_key")
	end)
end

-- Sensors events:
function sensor_10_flying_tile_init_1:on_activated()

	flying_tile_manager:init(map, "enemy_10")

end

function sensor_10_flying_tile_init_2:on_activated()

	flying_tile_manager:init(map, "enemy_10")

end

function sensor_10_flying_tile_launch_1:on_activated()

  if flying_tile_manager.is_launch == false then
      map:close_doors("door_10_w")
      map:close_doors("door_10_s")
    flying_tile_manager:launch(map, "enemy_10")
 end

end

function sensor_10_flying_tile_launch_2:on_activated()

  if flying_tile_manager.is_launch == false then
      map:close_doors("door_10_w")
      map:close_doors("door_10_s")
    flying_tile_manager:launch(map, "enemy_10")
 end

end
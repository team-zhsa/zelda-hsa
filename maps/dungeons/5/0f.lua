-- Lua script of map dungeons/5/1f.
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
  -- Blocks
  block_28_enemy:set_max_moves(0)
  -- Treasures
  treasure_manager:disappear_pickable(map, "pickable_26_small_key")
  treasure_manager:appear_pickable_when_enemies_dead(map, "enemy_26_", "pickable_26_small_key")

  -- Doors
  map:set_doors_open("door_26_n", true)
  door_manager:open_when_enemies_dead(map, "enemy_26_", "door_26_n", false)
end)

sensor_26_door:register_event("on_activated", function()
  door_manager:close_if_enemies_not_dead(map, "enemy_26_", "door_26_n")
end)

-- Room 28 enable block moving when enemies are killed
for enemy in map:get_entities("enemy_28_block_") do
  enemy:register_event("on_dead", function()
    if not map:has_entities("enemy_28_block_") then
      block_28_enemy:set_max_moves(1)
    end 
  end)
end

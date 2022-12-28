-- Lua script of map dungeons/2/b1 bis.
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
local cannonball_manager = require("scripts/maps/cannonball_manager")
cannonball_manager:create_cannons(map, "cannon_")
local water_delay = 500
-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
	if game:get_value("dungeon_2_b2_24_pool_full") == false then
		for tile in map:get_entities("static_water_") do
   		tile:set_enabled(false)
		end  
    dynamic_water_1:set_enabled(false)
    switch_24_pool_empty:set_activated(true)
    switch_24_pool_fill:set_activated(false)
  elseif game:get_value("dungeon_2_b2_24_pool_full") ~= false then
    switch_24_pool_empty:set_activated(false)
    switch_24_pool_fill:set_activated(true)
    game:set_value("dungeon_2_b2_24_pool_full", true)
	end
  dynamic_water_2:set_enabled(false)
  dynamic_water_3:set_enabled(false)
  dynamic_water_4:set_enabled(false)
	separator_manager:manage_map(map)
	map:set_doors_open("door_33_e", false)
	map:set_doors_open("door_34_w", false)
	map:set_doors_open("door_29_n", false)
	map:set_doors_open("door_21_s", false)
	door_manager:open_when_switch_activated(map, "switch_33_door", "door_33_e")
	door_manager:open_when_switch_activated(map, "switch_27_door", "door_27_n")
	door_manager:open_when_switch_activated(map, "switch_24_door", "door_29_n")
	door_manager:open_when_switch_activated(map, "switch_34_door", "door_29_n")
  -- You can initialize the movement and sprites of various
  -- map entities here.
end)

-- Pool fill switch mechanism
-- The switch fills up the swimming pool
function switch_24_pool_fill:on_activated()
  hero:freeze()
  switch_24_pool_empty:set_activated(false)
  sol.audio.play_sound("water_fill_begin")
  sol.audio.play_sound("water_fill")
  local water_tile_index = 4
  sol.timer.start(water_delay, function()
    local next_tile = map:get_entity("dynamic_water_" .. water_tile_index)
    local previous_tile = map:get_entity("dynamic_water_" .. water_tile_index + 1)
    if next_tile == nil then
      hero:unfreeze()
      return false
    end
    next_tile:set_enabled(true)
    if previous_tile ~= nil then
      previous_tile:set_enabled(false)
    end
    water_tile_index = water_tile_index - 1
    return true
  end)
  for tile in map:get_entities("static_water_") do
    tile:set_enabled(true)
  end
	game:set_value("dungeon_2_b2_24_pool_full", true)
end

-- Pool empty switch mechanism
-- The switch drains the swimming pool
function switch_24_pool_empty:on_activated()
  hero:freeze()
  switch_24_pool_fill:set_activated(false)
  sol.audio.play_sound("water_drain_begin")
  sol.audio.play_sound("water_drain")
  local water_tile_index = 1
  sol.timer.start(water_delay, function()
    local next_tile = map:get_entity("dynamic_water_" .. water_tile_index + 1)
    local previous_tile = map:get_entity("dynamic_water_" .. water_tile_index)
    if next_tile ~= nil then    
      next_tile:set_enabled(true)
    end
    if previous_tile ~= nil then
      previous_tile:set_enabled(false)
    end
    water_tile_index = water_tile_index + 1
    if next_tile == nil then
      hero:unfreeze()
      return false
    end
    return true
  end)
  for tile in map:get_entities("static_water_") do
    tile:set_enabled(false)
  end
	game:set_value("dungeon_2_b2_24_pool_full", false)
end
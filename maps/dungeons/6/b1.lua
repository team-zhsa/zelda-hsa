-- Lua script of map dungeon_6/1f.
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
	water_level_manager:check_water_level(map)
	separator_manager:manage_map(map)

end
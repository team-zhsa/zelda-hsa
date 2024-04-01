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
local water_level_manager = require("scripts/maps/water_level_manager")

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  water_level_manager:check_water_level(map)
	if water_level_manager:get_water_level(map) == "high" then
    switch_24_pool_empty:set_activated(false)
    switch_24_pool_fill:set_activated(true)
  else
    switch_24_pool_empty:set_activated(true)
    switch_24_pool_fill:set_activated(false)
	end
	separator_manager:manage_map(map)
	map:set_doors_open("door_33_e", false)
	map:set_doors_open("door_34_w", false)
	map:set_doors_open("door_29_n", false)
	map:set_doors_open("door_21_s", false)
	door_manager:open_when_switch_activated(map, "switch_33_door", "door_33_e")
	door_manager:open_when_switch_activated(map, "switch_27_door", "door_27_n")
	door_manager:open_when_switch_activated(map, "switch_24_door", "door_29_n")
	door_manager:open_when_switch_activated(map, "switch_34_door", "door_29_n")
end)

-- Pool fill switch mechanism
-- The switch fills up the swimming pool
switch_24_pool_fill:register_event("on_activated", function()
  switch_24_pool_empty:set_activated(false)
  water_level_manager:raise_water_level(map)
end)

-- Pool empty switch mechanism
-- The switch drains the swimming pool
switch_24_pool_empty:register_event("on_activated", function()
  switch_24_pool_fill:set_activated(false)
  water_level_manager:lower_water_level(map)
end)
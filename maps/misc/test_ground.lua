-- Lua script of map misc/test_ground.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()
local light_manager = require("scripts/maps/light_manager")
require("scripts/states/running")
local credits = require("scripts/menus/credits")
local house_manager = require("scripts/maps/house_manager")

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	light_manager:init(map)
--	hero:fall_from_ceiling(320)
  map:set_light(0)
--	sol.menu.start(map, credits, true)
end


function tp:on_activated()
		dungeon_tp:set_enabled(false)
end

local text = sol.text_surface.create{
	text_key = "version",
	horizontal_alignment = "center",
	font = "alttp",
}

function map:on_draw(dst_surface)
	text:draw(dst_surface, 160, 220)
end

function sensor_light:on_activating()
	map:set_light(0)
end
-- Lua script of map misc/test_ground.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()
--require("scripts/maps/temperature_manager")
require("scripts/states/running")
local credits = require("scripts/menus/credits")
local house_manager = require("scripts/maps/house_manager")
local fall_manager = require("scripts/maps/ceiling_drop_manager")
local treasure_manager = require("scripts/maps/treasure_manager")


-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	fall_manager:create("pickable")
	treasure_manager:disappear_pickable(map, "pendant")
--	house_manager:init(map)
--	hero:fall_from_ceiling(320)
  --map:set_light(0)
--	sol.menu.start(map, credits, true)
end



function tp:on_activated()
	treasure_manager:appear_pickable(map, "pendant")
end

local text = sol.text_surface.create{
	text_key = "version",
	horizontal_alignment = "center",
	font = "alttp",
}
local t = sol.sprite.create("menus/title_triforce")
t:set_animation("triforce")

function map:on_draw(dst_surface)
	text:draw(dst_surface, 160, 220)
	t:draw(dst_surface, 88, 88)
end


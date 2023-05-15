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


local text = sol.text_surface.create{
	text_key = "version",
	horizontal_alignment = "center",
	font = "alttp",
}
local t = sol.sprite.create("menus/title_triforce")
t:set_animation("triforce")

local map_surface = sol.surface.create("menus/map/outside_world_map.png")
local ds = 0.1
local smax = 8
local timer = 100
local sx, sy 
local nsx, nsy = 0.5, 0.5

function map:on_draw(dst_surface)
	map_surface:set_transformation_origin(120, 90)
	map_surface:draw(dst_surface)
	

	text:draw(dst_surface, 160, 220)
	t:draw(dst_surface, 88, 88)
end

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	
	sol.timer.start(game, 40, function()
		nsx = nsx + ds
		nsy = nsy + ds
		map_surface:set_scale(nsx, nsy)
		print(nsx)
		return nsx < smax
	end)
	
	
	fall_manager:create("pickable")
	treasure_manager:disappear_pickable(map, "pendant")
	
	sol.timer.start(map, 2000, function()
		local i = 1
		for entity in map:get_entities("a_") do -- C.E. for animation
			entity:set_visible(false)
		end
		sol.timer.start(map, 1000, function() -- real tile
			for tile in map:get_entities("d_"..i) do
				tile:set_enabled(false)
			end
			for entity in map:get_entities("a_"..i) do -- C.E. for animation
				entity:set_visible(true)
				local sprite = entity:get_sprite()
				sprite:set_animation("destroy")
			end
			i = i + 1
			return true
		end)
	end)
	
	--	house_manager:init(map)
	--	hero:fall_from_ceiling(320)
  --map:set_light(0)
	--	sol.menu.start(map, credits, true)
end


function tp:on_activated()
	treasure_manager:appear_pickable(map, "pendant")
end



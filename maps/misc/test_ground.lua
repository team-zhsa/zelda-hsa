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

local t = sol.sprite.create("menus/title_triforce")
t:set_animation("triforce")

local ds = 0.1
local smax = 8
local timer = 100
local sx, sy 
local nsx, nsy = 0.5, 0.5

function map:on_draw(dst_surface)
	
	t:draw(dst_surface, 88, 88)
end

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	
	sol.timer.start(game, 40, function()
		nsx = nsx + ds
		nsy = nsy + ds
		--print(nsx)
		return nsx < smax
	end)

	--for stream in map:get_entities("water_stream_17_1_") do
		stream:set_direction(0)
		sol.timer.start(1000, function()
			local direction = (stream:get_direction() + 2) % 8
			stream:set_direction(direction)
			print(direction)
			return true  -- To call the timer again (with the same delay).
		end)
	--end

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



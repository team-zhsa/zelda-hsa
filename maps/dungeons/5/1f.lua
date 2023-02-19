local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local door_manager = require("scripts/maps/door_manager")
local enemy_manager = require("scripts/maps/enemy_manager")
local separator_manager = require("scripts/maps/separator_manager")
local switch_manager = require("scripts/maps/switch_manager")
local treasure_manager = require("scripts/maps/treasure_manager")
local separator_manager = require("scripts/maps/separator_manager.lua")

map:register_event("on_started", function()
	separator_manager:manage_map(map)
end)

function collapse_tiles_7()
	local i = 1
	collapse_timer = sol.timer.start(map, 1000, function() -- real tile
		local collapsing_tile = map:get_entity("collapsing_tile_7_"..i)
		local collapsing_entity = map:get_entity("collapsing_entity_7_"..i)
		collapsing_tile:set_enabled(false)
		collapsing_entity:set_visible(true)-- C.E. for animation
		local sprite = collapsing_entity:get_sprite()
		sprite:set_animation("destroy")
		i = i + 1
		if collapsing_tile == nil then return false end
		return true
	end)
end

function appear_tiles_7()
	if collapse_timer ~= nil then collapse_timer:stop() end
	for entity in map:get_entities("collapsing_entity_7_") do -- C.E. for animation
		entity:set_visible(false)
	end
	for tile in map:get_entities("collapsing_tile_7_") do
		tile:set_enabled(true)
	end
end

for sensor in map:get_entities("sensor_7_tile_") do
	sensor:register_event("on_activated", function()
		sol.timer.start(map, 500, function()
			collapse_tiles_7()
		end)
		sensor_7_tile_1:set_enabled(false)
		sensor_7_tile_2:set_enabled(false)
	end)
end

for sensor in map:get_entities("sensor_7_sensor_") do
  -- Enables the sensors to close the doors
  sensor:register_event("on_activated", function()
    for sensor in map:get_entities("sensor_7_tile_") do
      sensor:set_enabled(true)
			appear_tiles_7()
    end
  end)
end
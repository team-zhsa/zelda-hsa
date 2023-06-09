local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local door_manager = require("scripts/maps/door_manager")
local enemy_manager = require("scripts/maps/enemy_manager")
local separator_manager = require("scripts/maps/separator_manager")
local switch_manager = require("scripts/maps/switch_manager")
local treasure_manager = require("scripts/maps/treasure_manager")
local separator_manager = require("scripts/maps/separator_manager")
local hole_manager = require("scripts/maps/hole_manager")

map:register_event("on_started", function()
	separator_manager:manage_map(map)

	-- Collapsing tiles
	for sensor in map:get_entities("sensor_7_tile_") do
		sensor:set_enabled(true)
		appear_tiles_7()
	end
	hole_manager:enable_a_tiles(map)

	-- Treasures
	if not game:get_value("dungeon_5_1f_30_rupees", true) then
		treasure_manager:disappear_chest(map, "chest_30_rupees")
	end
	treasure_manager:appear_chest_when_enemies_dead(map, "enemy_30_", "chest_30_rupees")

	-- Doors
	map:set_doors_open("door_30_w", true)
	map:set_doors_open("door_30_s", true)
	door_manager:open_when_enemies_dead(map, "enemy_30_", "door_30_w", sound)
	door_manager:open_when_enemies_dead(map, "enemy_30_", "door_30_s", sound)
end)

for sensor in map:get_entities("sensor_30_door_") do
	sensor:register_event("on_activated", function()
		map:close_doors("door_30_w")
		map:close_doors("door_30_s")
		sensor:set_enabled(false)
	end)
end

for sensor in map:get_entities("sensor_20_floor_a_") do
	sensor:register_event("on_activated", function()
		hole_manager:enable_b_tiles(map, "common/secret_discover_minor")
	end)
end


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
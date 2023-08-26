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
	map:set_doors_open("door_10_n", true)
	map:set_doors_open("door_30_w", true)
	map:set_doors_open("door_30_s", true)
	door_manager:open_when_enemies_dead(map, "enemy_30_", "door_30_w", sound)
	door_manager:open_when_enemies_dead(map, "enemy_30_", "door_30_s", sound)

	-- Switches
	switch_manager:activate_switch_if_savegame_exist(map, "switch_15_door_1", "dungeon_5_1f_switch_15_1")
	switch_manager:activate_switch_if_savegame_exist(map, "switch_15_door_2", "dungeon_5_1f_switch_15_2")
	switch_manager:activate_switch_if_savegame_exist(map, "switch_15_door_3", "dungeon_5_1f_switch_15_3")
	switch_manager:activate_switch_if_savegame_exist(map, "switch_15_door_4", "dungeon_5_1f_switch_15_4")
	switch_manager:activate_switch_if_savegame_exist(map, "switch_15_door_5", "dungeon_5_1f_switch_15_5")
	switch_manager:activate_switch_if_savegame_exist(map, "switch_15_door_6", "dungeon_5_1f_switch_15_6")
	switch_manager:activate_switch_if_savegame_exist(map, "switch_15_door_7", "dungeon_5_1f_switch_15_7")
end)

-- Room 15 switch puzzle
for i = 1,10 do
	for switch in map:get_entities("switch_15_door_"..i) do
		switch:register_event("on_activated", function()
			audio_manager:play_sound("common/secret_discover_minor")
			game:set_value("dungeon_5_1f_switch_15_"..i, true)
			if game:get_value("dungeon_5_1f_switch_15_1") and game:get_value("dungeon_5_1f_switch_15_2")
			and game:get_value("dungeon_5_1f_switch_15_3") and game:get_value("dungeon_5_1f_switch_15_4")
			and game:get_value("dungeon_5_1f_switch_15_5") and game:get_value("dungeon_5_1f_switch_15_6")
			and game:get_value("dungeon_5_1f_switch_15_7") and game:get_value("dungeon_5_1f_switch_15_8")
			and game:get_value("dungeon_5_1f_switch_15_9") and game:get_value("dungeon_5_1f_switch_15_10") then
				map:lauch_staircase_15_cutscene()
			end
		end)
	end
end

-- Room 15 staircase cutscene
function map:launch_staircase_15_cutscene()
end

s:register_event("on_activated", function()
	map:enable_staircase_15()
end)

function map:enable_staircase_15()
	tile_staircase_30_1:set_position(920 - 8, 1400 - 8, 1)
end

-- Door events
sensor_10_door_1:register_event("on_activated", function()
	map:close_doors("door_10_n")
end)

sensor_10_door_2:register_event("on_activated", function()
	map:set_doors_open("door_10_n", false)
end)

sensor_10_door_3:register_event("on_activated", function()
	map:set_doors_open("door_10_n", false)
end)

sensor_10_door_4:register_event("on_activated", function()
	map:set_doors_open("door_10_n", false)
end)

sensor_10_door_5:register_event("on_activated", function()
	map:set_doors_open("door_10_n", true)
end)

sensor_10_door_6:register_event("on_activated", function()
	map:set_doors_open("door_10_n", true)
end)

for sensor in map:get_entities("sensor_30_door_") do
	sensor:register_event("on_activated", function()
		map:close_doors("door_30_w")
		map:close_doors("door_30_s")
		sensor:set_enabled(false)
	end)
end

-- Floor tiles
for sensor in map:get_entities("sensor_20_floor_a_") do
	sensor:register_event("on_activated", function()
		hole_manager:enable_b_tiles(map, "common/secret_discover_minor")
	end)
end

-- Collapsing tiles
function collapse_tiles_5()
	local i = 1
	collapse_timer = sol.timer.start(map, 1000, function() -- real tile
		local collapsing_tile = map:get_entity("collapsing_tile_5_"..i)
		local collapsing_entity = map:get_entity("collapsing_entity_5_"..i)
		collapsing_tile:set_enabled(false)
		collapsing_entity:set_visible(true)-- C.E. for animation
		local sprite = collapsing_entity:get_sprite()
		sol.audio.play_sound("jump")
		sprite:set_animation("destroy")
		i = i + 1
		if collapsing_tile == nil then return false end
		return true
	end)
end

function appear_tiles_5()
	if collapse_timer ~= nil then collapse_timer:stop() end
	for entity in map:get_entities("collapsing_entity_5_") do -- C.E. for animation
		entity:set_visible(false)
	end
	for tile in map:get_entities("collapsing_tile_5_") do
		tile:set_enabled(true)
	end
end

for sensor in map:get_entities("sensor_5_tile_") do
	sensor:register_event("on_activated", function()
		sol.timer.start(map, 700, function()
			collapse_tiles_5()
		end)
		sensor_5_tile_1:set_enabled(false)
		sensor_5_tile_2:set_enabled(false)
	end)
end

for sensor in map:get_entities("sensor_5_sensor_") do
  -- Enables the sensors to collapse the tiles.
  sensor:register_event("on_activated", function()
    for sensor in map:get_entities("sensor_5_tile_") do
      sensor:set_enabled(true)
			appear_tiles_5()
    end
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
		sol.audio.play_sound("jump")
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
  -- Enables the sensors to collapse the tiles
  sensor:register_event("on_activated", function()
    for sensor in map:get_entities("sensor_7_tile_") do
      sensor:set_enabled(true)
			appear_tiles_7()
    end
  end)
end
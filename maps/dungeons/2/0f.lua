-- Lua script of map dungeons/2/1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local separator_manager = require("scripts/maps/separator_manager.lua")
local camera_meta = require("scripts/meta/camera.lua")
local audio_manager = require("scripts/audio_manager.lua")
local cannonball_manager = require("scripts/maps/cannonball_manager")
cannonball_manager:create_cannons(map, "cannon_")

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started(destination)
	separator_manager:manage_map(map)
	map:open_doors("door_19_s")
  map:open_doors("door_3_s")
  map:open_doors("door_8_n")
	chest_20_blue_key:set_enabled(false)
	if not game:get_value("dungeon_2_compass", true) then
		chest_30_compass:set_enabled(false)
	else
    chest_30_compass:set_enabled(true)
  end
  
  if not game:get_value("dungeon_2_1f_11_chest_small_key", true) then
		chest_11_small_key:set_enabled(false)
	else
    chest_11_small_key:set_enabled(true)
	end
  
	map:set_light(1)
end


function switch_28_1:on_activated()
  if switch_28_2:is_activated() and switch_28_3:is_activated() and switch_28_4:is_activated() then
    map:open_doors("door_27_n1")
    audio_manager:play_sound("common/secret_discover_minor")
  end
end

function switch_28_2:on_activated()
  if switch_28_1:is_activated() and switch_28_3:is_activated() and switch_28_4:is_activated() then
    map:open_doors("door_27_n1")
    audio_manager:play_sound("common/secret_discover_minor")
  end
end

function switch_28_3:on_activated()
  if switch_28_2:is_activated() and switch_28_1:is_activated() and switch_28_4:is_activated() then
    map:open_doors("door_27_n1")
    audio_manager:play_sound("common/secret_discover_minor")
  end
end

function switch_28_4:on_activated()
  if switch_28_2:is_activated() and switch_28_3:is_activated() and switch_28_1:is_activated() then
    map:open_doors("door_27_n1")
    audio_manager:play_sound("common/secret_discover_minor")
  end
end

function switch_20_chest:on_activated()
	chest_20_blue_key:set_enabled(true)
	audio_manager:play_sound("common/chest_appear")
end

function block_2:on_moved()
	map:open_doors("door_19_w")
end

function block_5:on_moved()
	map:open_doors("door_19_e")
end

function block_8:on_moved()
	map:open_doors("door_19_s")
end

local life = game:get_life()
for custom_entity in map:get_entities("torch_10") do
	function custom_entity:on_lit()
		if math.random(1, 2) == 1 then
			game:remove_life(life / 2)
		else
			game:set_value("dungeon_2_1f_10_collapse_ground", true)
			dynamic_10_light:set_enabled(false)
			dynamic_10_collapse:set_enabled(false)
		end
	end
end

function sensor_4_collapse:on_collision_explosion()
	dynamic_4_collapse:set_enabled(false)
	audio_manager:play_sound("common/secret_discover_minor")
	game:set_value("dungeon_2_1f_4_collapse_ground", true)
end

function npc_fairy:on_interaction()
	game:start_dialog("scripts.meta.map.fairy", function()
		game:set_life(game:get_max_life())
	end)
end

function switch_30_fire:on_activated()
	map:create_enemy({
		name = "auto_enemy",
		breed = "dungeons/bubble_red",
		x = 1400,
		y = 1304,
		layer = 0,
		direction = 1
	})
	switch_30_fire:set_activated(false)
end

function switch_30_chest:on_activated()
	audio_manager:play_sound("common/secret_discover_minor")
	chest_30_compass:set_enabled(true)
end

function switch_13_chest:on_activated()
  audio_manager:play_sound("common/chest_appear")
  chest_11_small_key:set_enabled(true)
end

function sensor_7_door:on_activated()
  map:set_doors_open("door_3_s", false)
  map:set_doors_open("door_8_n", false)
end

function sensor_7_door_2:on_activated()
  map:set_doors_open("door_3_s", false)
  map:set_doors_open("door_8_n", false)
end

function sensor_3_door:on_activated()
  map:close_doors("door_3_s")
  sensor_3_door:remove()
end

function switch_3_door:on_activated()
  map:open_doors("door_3_s")
end
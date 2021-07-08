-- Variables
local map = ...
local game = map:get_game()
local is_small_boss_active = false
local is_boss_active = false

-- Include scripts
require("scripts/multi_events")
local audio_manager = require("scripts/audio_manager")
local door_manager = require("scripts/maps/door_manager")
local enemy_manager = require("scripts/maps/enemy_manager")
local separator_manager = require("scripts/maps/separator_manager")
local switch_manager = require("scripts/maps/switch_manager")
local treasure_manager = require("scripts/maps/treasure_manager")

-- Map events


function map:on_started()
	separator_manager:manage_map(map)
	map:set_doors_open("door_17_n", false)
	map:set_doors_open("door_12_s", false)
	map:set_doors_open("door_18_n", false)
	map:set_doors_open("door_13_s", false)
	map:set_doors_open("door_15_s", true)
	map:set_doors_open("door_9_w", false)
	map:set_doors_open("door_8_e", false)
	switch_18_door:set_activated(false)
	switch_18_door_2:set_activated(false)
	switch_23_door:set_activated(false)
	door_manager:open_when_switch_activated(map, "switch_9_door", "door_15_s")
	door_manager:open_when_switch_activated(map, "switch_18_door", "door_17_n")
	door_manager:open_when_switch_activated(map, "switch_18_door_2", "door_18_n")
	treasure_manager:disappear_pickable(map, "red_key_6")
	if game:get_value("dungeon_2_1f_10_collapse_ground", true) then
		map:open_doors("door_9_w")
	end
	if game:get_value("dungeon_2_b1_door_6_11", true) then
		dynamic_6_wall_s:set_enabled(false)
  	dynamic_6_wall_s_top:set_enabled(false)
		dynamic_11_wall_n:set_enabled(false)
  	dynamic_11_wall_n_top:set_enabled(false)
	end
end

function switch_23_door:on_activated()
	map:open_doors("door_23_n")
	map:open_doors("door_18_s")
end

function sensor_14_door_15:on_activated()
	map:set_doors_open("door_15_s", false)
end

function door_6_s:on_opened()
  dynamic_6_wall_s:set_enabled(false)
  dynamic_6_wall_s_top:set_enabled(false)
	dynamic_11_wall_n:set_enabled(false)
  dynamic_11_wall_n_top:set_enabled(false)
  sol.audio.play_sound("common/secret_discover_minor")
end

function door_11_n:on_opened()
  dynamic_6_wall_s:set_enabled(false)
  dynamic_6_wall_s_top:set_enabled(false)
	dynamic_11_wall_n:set_enabled(false)
  dynamic_11_wall_n_top:set_enabled(false)
  sol.audio.play_sound("common/secret_discover_minor")
end

function torch_6:on_lit()
	treasure_manager:appear_pickable(map, "red_key_6")
end

function switch_9_door:on_activated()
	map:open_doors("door_15_s")
end

function npc_booth:on_interaction()
	game:start_dialog("maps.dungeons.2.hint_1", game:get_player_name())
end

function npc_booth_2:on_interaction()
	game:start_dialog("maps.dungeons.2.hint_1", game:get_player_name())
end
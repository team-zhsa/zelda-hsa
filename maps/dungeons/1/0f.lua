local map = ...
local game = map:get_game()
local separator_manager = require("scripts/maps/separator_manager.lua")
local timer_manager = require("scripts/maps/timer_manager")

function map:on_started()
	separator_manager:manage_map(map)
	map:close_doors("door_23_n1")
  boss_door:set_open(true)
  if game:get_value("dungeon_1_0f_door_28_29") then
    door_28_e_top:set_enabled(true)
    door_28_e_sensor:set_enabled(false)
    door_28_e_tile:set_enabled(false)
  else
    door_28_e_top:set_enabled(false)
    door_28_e_sensor:set_enabled(true)
    door_28_e_tile:set_enabled(true)
  end
end

function door_28_e_sensor:on_collision_explosion()
  door_28_e_top:set_enabled(true)
  door_28_e_tile:set_enabled(false)
  sol.audio.play_sound("common/secret_discover_minor")
  game:set_value("dungeon_1_0f_door_28_29", true)
end

function sensor_e_22_rsp:on_activated()
  hero:save_solid_ground()
end

function switch_door_23_n1:on_activated()
  map:open_doors("door_23_n1")
  timer_manager:start_timer(map, 15000, "countdown", function() --Timer for 15 seconds
    map:close_doors("door_23_n1")
    switch_door_23_n1:set_activated(false)
  end)
end
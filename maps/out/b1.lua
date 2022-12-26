-- Lua script of map out/b1.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager.lua")

map:register_event("on_started", function()
	game:show_map_name("west_mountains")
	map:set_digging_allowed(true)
end)

sensor_cutscene:register_event("on_activated", function()
	if game:is_step_last("agahnim_met") then
    map:set_cinematic_mode(true, options)
    hero:freeze()
    hero:set_direction(0)
    audio_manager:play_music("cutscenes/kaepora_gaebora")
    local owl_movement_to_position = sol.movement.create("target")
    owl_movement_to_position:set_target(owl_position)
    owl_movement_to_position:set_ignore_obstacles(true)
    owl_movement_to_position:set_ignore_suspend(true)
    owl_movement_to_position:set_speed(60)
    owl_movement_to_position:start(owl, function()
      owl_dialog()
    end)
  end
end)

function owl_dialog()
  game:start_dialog("maps.kaepora_gaebora.owl_13", function(answer)
    if answer == 1 then
      owl_dialog()
    elseif answer == 2 then
      game:start_dialog("maps.out.west_mountains.song_learnt", function()
        hero:start_treasure("song_2_fire")
        game:set_step_done("dungeon_3_started")
        local owl_movement_leave = sol.movement.create("target")
        owl_movement_leave:set_target(1328, 328)
        owl_movement_leave:set_ignore_obstacles(true)
        owl_movement_leave:set_ignore_suspend(true)
        owl_movement_leave:set_ignore_suspend(true)
        owl_movement_leave:set_speed(60)
        owl_movement_leave:start(owl, function()
          map:set_cinematic_mode(false, options)
          audio_manager:play_music_fade(map, "outside/mountains")
          hero:unfreeze()
        end)
      end) 
    end
  end)
end

-- Handle boulders spawning depending on activated sensor.
for sensor in map:get_entities("sensor_activate_boulder_") do
  sensor:register_event("on_activated", function(sensor)
    spawner_boulder_1:start()
    spawner_boulder_2:start()
		spawner_boulder_3:start()
		spawner_boulder_4:start()
  end)
end
for sensor in map:get_entities("sensor_deactivate_boulder_") do
  sensor:register_event("on_activated", function(sensor)
    spawner_boulder_1:stop()
    spawner_boulder_2:stop()
		spawner_boulder_3:stop()
		spawner_boulder_4:stop()
  end)
end


-- Remove spawned boulders when too far of the mountain.
for spawner in map:get_entities("spawner_boulder_") do
  spawner:register_event("on_enemy_spawned", function(spawner, enemy)
    enemy:register_event("on_position_changed", function(enemy)
      local _, y, _ = enemy:get_position()
      if y > 2000 then
        enemy:remove()
      end
    end)
  end)
end

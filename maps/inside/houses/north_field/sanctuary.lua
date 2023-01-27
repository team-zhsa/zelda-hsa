-- Lua script of map inside/houses/north_west/sanctuary.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  --if game:get_value("priest_kidnapped") == true then
    --sol.audio.play_music("inside/sanctuary_1")
    --priest:set_enabled(false)
  --else ---
    if game:is_step_last("world_map_obtained") then -- Tells the legend.
      sol.audio.play_music("inside/sanctuary_3")
      priest:set_enabled(true)
      door:set_enabled(true)
      dialog:set_enabled(true)
      npc_agahnim:set_enabled(false)
    elseif game:is_step_last("priest_kidnapped") then -- Meet Agahnim
      sol.audio.play_music("inside/sanctuary_3")
      priest:set_enabled(false)
      door:set_enabled(false)
      dialog:set_enabled(false)
      npc_agahnim:set_enabled(true)
    else
      if game:get_time() >= 7 and game:get_time() < 15 then
        sol.audio.play_music("inside/sanctuary_3")
        priest:set_enabled(true)
        door:set_enabled(true)
        dialog:set_enabled(true)
        npc_agahnim:set_enabled(false)
      else -- The priest isn't present.
        priest:set_enabled(false)
        door:set_enabled(false)
        dialog:set_enabled(false)
        npc_agahnim:set_enabled(false)
      end
    end
  --end
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

sensor_cutscene:register_event("on_activated", function()
  if game:is_step_last("priest_kidnapped") then
    map:set_cinematic_mode(true, options)
    local agahnim_movement_to_position = sol.movement.create("straight")
    agahnim_movement_to_position:set_ignore_obstacles(true)
    agahnim_movement_to_position:set_ignore_suspend(true)
    agahnim_movement_to_position:set_angle(3 * math.pi / 2)
    agahnim_movement_to_position:set_speed(104)
    agahnim_movement_to_position:set_max_distance(104)
    agahnim_movement_to_position:start(npc_agahnim, function()
      game:start_dialog("maps.houses.north_field.sanctuary.agahnim_1", game:get_player_name(), function()
        local agahnim_movement_to_leave = sol.movement.create("straight")
        agahnim_movement_to_position:set_ignore_obstacles(true)
        agahnim_movement_to_position:set_ignore_suspend(true)
        agahnim_movement_to_position:set_angle(math.pi / 2)
        agahnim_movement_to_position:set_speed(104)
        agahnim_movement_to_position:set_max_distance(104)
        agahnim_movement_to_position:start(npc_agahnim, function()
          npc_agahnim:set_enabled(false)
          game:set_step_done("agahnim_met")
          map:set_cinematic_mode(false, options)
        end)
      end)
    end)
  end
end)

dialog:register_event("on_interaction", function()
  map:set_cinematic_mode(true, options)
  hero:freeze()
  game:start_dialog("maps.houses.north_field.sanctuary.priest_1", game:get_player_name(), function()
    sol.timer.start(map, 2000, function()
      if game:is_step_last("world_map_obtained") then
        tell_legend()
      elseif game:is_step_last("priest_met") then
        game:start_dialog("maps.houses.north_field.sanctuary.priest_5", function()
          return_hero()
        end)
      end
    end)
  end)    
end)

function return_hero()
  hero:unfreeze()
  priest:get_sprite():set_direction(1)
  map:set_cinematic_mode(false, options)
end

function tell_legend()
  priest:get_sprite():set_animation("reading")
  priest:get_sprite():set_direction(3)
  game:start_dialog("maps.houses.north_field.sanctuary.priest_2", function()
    sol.timer.start(map, 250, function()
      game:start_dialog("maps.houses.north_field.sanctuary.priest_3", function()
        sol.timer.start(map, 250, function()
          priest:get_sprite():set_animation("stopped")
          game:start_dialog("maps.houses.north_field.sanctuary.priest_4", game:get_player_name(), function(answer)
            if answer == 1 then
              tell_legend()
            else
              return_hero()
              game:set_step_done("priest_met")
            end
          end)
        end)
      end)
    end)
  end)
end

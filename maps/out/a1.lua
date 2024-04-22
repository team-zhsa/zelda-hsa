-- Lua script of map out/a1.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
	game:show_map_name("ruins")
	map:set_digging_allowed(true)
    -- Music

end)

sensor_cutscene:register_event("on_activated", function()
	if game:is_step_last("priest_met") then
    map:set_cinematic_mode(true, options)
    hero:freeze()
    hero:set_direction(1)
    sol.audio.play_music("cutscenes/kaepora_gaebora")
    local owl_movement_to_position = sol.movement.create("target")
    owl_movement_to_position:set_target(owl_4_position)
    owl_movement_to_position:set_ignore_obstacles(true)
    owl_movement_to_position:set_ignore_suspend(true)
    owl_movement_to_position:set_speed(60)
    owl_movement_to_position:start(owl_4, function()
      owl_dialog()
    end)
  end
end)

function owl_dialog()
  game:start_dialog("maps.out.north_field.kaepora_gaebora_ruins", function(answer)
    if answer == 1 then
      owl_dialog()
    elseif answer == 2 then
      game:set_step_done("dungeon_1_started")
      local owl_movement_leave = sol.movement.create("target")
      owl_movement_leave:set_target(1328, 328)
      owl_movement_leave:set_ignore_obstacles(true)
      owl_movement_leave:set_ignore_suspend(true)
      owl_movement_leave:set_speed(60)
      owl_movement_leave:start(owl_4, function()
        map:set_cinematic_mode(false, options)
        hero:unfreeze()
      end) 
    end
  end)
end
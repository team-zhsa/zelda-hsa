-- Variables
local owl_manager = {}

-- Include scripts
local audio_manager = require("scripts/audio_manager")

-- Function that makes it possible to make the owl appear to launch a dialogue.
function owl_manager:appear(map, step, callback)

    local game = map:get_game()
    local hero = map:get_entity("hero")
    local owl = map:get_entity("owl_"..step)
    local x_hero,y_hero = hero:get_position()
    local x_owl,y_owl, l_owl = owl:get_position()
    local distance_owl = owl:get_distance(hero)
    local owl_shadow = map:create_custom_entity{
      x = x_owl,
      y = y_owl + 32,
      width = 16,
      height = 8,
      direction = 0,
      layer = l_owl ,
      sprite ="entities/shadows/owl"
    }
    map:start_coroutine(function()
      local options = {
        entities_ignore_suspend = {owl, owl_shadow}
      }
      map:set_cinematic_mode(true, options)
      -- Init and launch cinematic mode
      -- Init music
      audio_manager:play_music("cutscenes/kaepora_gaebora")
     -- Init hero
      hero:set_direction(1)
      -- Init owl shadow
      owl_shadow:get_sprite():set_animation("walking")
      owl_shadow:get_sprite():set_direction(1)
      owl_shadow:get_sprite():set_blend_mode("multiply")
     -- Init owl
      owl:set_enabled(true)
      owl:get_sprite():set_animation("walking")
      owl:get_sprite():set_direction(3)
      owl:bring_to_front()
      -- Init movement 1
      local timer_sound = sol.timer.start(owl, 500, function()
        if owl:get_distance(hero) < 120 then  
          --audio_manager:play_sound("misc/owl_fly_in")
        end
        return true
      end)
      timer_sound:set_suspended_with_map(false)
      local m = sol.movement.create("target")
      m:set_target(x_hero, y_hero - 32)
      m:set_speed(60)
      m:set_ignore_obstacles(true)
      m:set_ignore_suspend(true)
      function m:on_position_changed()
        local x_owl,y_owl = owl:get_position()
        local distance = owl:get_distance(hero)
        local offset = (distance_owl - distance) / distance_owl * 32
        owl_shadow:set_position(x_owl, y_owl + 32 - offset)
      end
      movement(m, owl)
      timer_sound:stop()
      owl_shadow:set_enabled(false)
      owl:get_sprite():set_animation("talking")
      owl_shadow:get_sprite():set_animation("talking")
      local timer_sound2 = sol.timer.start(owl, 1000, function()
        local index = math.random(1,2)
--        audio_manager:play_sound("misc/owl_hoot" .. index)
        return true
      end)
      timer_sound2:set_suspended_with_map(false)
      
      function tell_dialog()
        game:start_dialog("maps.kaepora_gaebora.owl_"..step, answer)
        if answer == 1 then
          tell_dialog()
        else
          fly_away()
        end
      end
      tell_dialog()
      function fly_away()
      timer_sound2:stop()
      owl:get_sprite():set_animation("walking")
      owl:get_sprite():set_direction(1)
      owl_shadow:get_sprite():set_animation("walking")
      owl_shadow:get_sprite():set_direction(1)
      -- Init movement 2
      owl_shadow:set_enabled(true)
--      audio_manager:play_sound("misc/owl_fly_away")
      local position = map:get_entity("owl_"..step.."_position")
      local m2 = sol.movement.create("target")
      m2:set_target(position)
      m2:set_speed(120)
      m2:set_ignore_obstacles(true)
      m2:set_ignore_suspend(true)
      function m2:on_position_changed()
        local x_owl,y_owl = owl:get_position()
        local distance = owl:get_distance(hero)
        local offset = (distance_owl - distance) / distance_owl * 32
        owl_shadow:set_position(x_owl, y_owl + 32 - offset)
      end
      movement(m2, owl)
      owl:set_enabled(false)
      owl_shadow:set_enabled(false)
      -- Launch callback if exist
      if callback ~= nil then
        callback()
      end
      game:set_value("kaepora_gaebora_"..step, true)
      map:set_cinematic_mode(false, options)
    end
    end)

end




return owl_manager

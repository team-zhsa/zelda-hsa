local carried_meta = sol.main.get_metatable("carried_object")
require ("scripts/multi_events")
local audio_manager=require "scripts/audio_manager"
local entity_manager = require("scripts/maps/entity_manager")

local m = sol.movement.create("straight")

carried_meta:register_event("on_thrown", function(entity)

    audio_manager:play_sound("hero/throw")
    local map = entity:get_map()
    local hero = map:get_hero()
    local shadow = entity:get_sprite("shadow") or entity:create_sprite("entities/shadows/shadow", "shadow_override")

    entity:bring_sprite_to_back(shadow)
    if map:is_sideview() then --Make me follow gravity


      m:set_angle(hero:get_sprite():get_direction()*math.pi/2)
      m:set_speed(92)
      m:start(entity)

      function m:on_position_changed(x,y)
        local off_y=0

        while not entity:test_obstacles(0, off_y) do
          off_y=off_y+1
        end
        if off_y > 24 then
          shadow:set_animation("small")
        elseif off_y > 16 then
          shadow:set_animation("medium_high")
        elseif off_y > 8 then
          shadow:set_animation("medium_low")
        else
          shadow:set_animation("big") 
        end
        shadow:set_xy(0, off_y+2)
      end

    end

  end)

carried_meta:register_event("on_breaking", function(entity) 
    
    
    local shadow = entity:get_sprite("shadow")    
    if shadow then
      entity:remove_sprite(shadow)
      error("[Breaking] The shadow should already have been removed at this point")
    else
      debug_print("[Breaking] OK, there is still no shadow at this point")
    end
    
    shadow = entity:get_sprite("shadow_override")    
    if shadow then
      entity:remove_sprite(shadow)
    end
  end)

carried_meta:register_event("on_lifted", function(entity)
    local shadow = entity:get_sprite("shadow")    
    if shadow then
      error("the shadow should already have been removed at this point")
    end
  end)
carried_meta:register_event("on_removed", function(entity)
    if entity:get_ground_below() =="hole" then
      entity_manager:create_falling_entity(entity)
    end
  end)

carried_meta:register_event("on_created", function(entity)

    local map=entity:get_map()
    local shadow = entity:get_sprite("shadow")
    if shadow then
      debug_print "(carried object creation time) SHADOW BE GONE !"
      entity:remove_sprite(shadow)
    end
    if map:is_sideview() then
      for name, s in entity:get_sprites() do
        debug_print ("shifting sprite layer "..name)
        s:set_xy(0,2)
      end
    end

  end)

carried_meta:register_event("on_post_draw", function(entity, surface)
    show_hitbox(entity)
  end)
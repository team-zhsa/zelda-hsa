local carried_meta = sol.main.get_metatable("carried_object")
require ("scripts/multi_events")
local audio_manager=require "scripts/audio_manager"
local entity_manager = require("scripts/maps/entity_manager")

local m = sol.movement.create("straight")

carried_meta:register_event("on_thrown", function(entity)

    audio_manager:play_sound("throw")
    local map = entity:get_map()
    local hero = map:get_hero()
    local shadow = entity:get_sprite("shadow") or entity:create_sprite("entities/shadows/shadow", "shadow_override")

    entity:bring_sprite_to_back(shadow)
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
			entity:bring_sprite_to_back(shadow)
      debug_print "(carried object creation time) SHADOW BE GONE !"
      entity:remove_sprite(shadow)
    end

  end)

carried_meta:register_event("on_post_draw", function(entity, surface)
    show_hitbox(entity)
  end)
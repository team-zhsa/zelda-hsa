--Bomb arrow : lies like an arrow, explodes on impact like a bomb.

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local audio_manager=require "scripts/audio_manager"

-- Event called when the custom entity is initialized.
function entity:on_created()

  entity.apply_cliffs=true,
  entity:set_origin(4,4)
  entity:set_can_traverse(false)
  entity:set_can_traverse("switch", true)
  entity:set_can_traverse("sensor", true)
  entity:set_can_traverse("stream", true)
  entity:set_can_traverse("stairs", true)
  entity:set_can_traverse("crystal_block", true)
  entity:set_can_traverse("pickable", true)
  entity:set_can_traverse("explosion", true)
  entity:set_can_traverse("teletransporter", true)
  entity:set_can_traverse("custom_entity", function(e)
      return e:is_traversable_by("custom_entity")
    end)
  entity:set_can_traverse("jumper", true)
  entity:set_can_traverse("npc", function(entity, other)
      --TODO check for NPC type when a function like "npc:is_generalized()" is available
      return other:is_drawn_in_y_order() or other:is_traversable()
    end)

  entity:set_can_traverse_ground("hole", true)
  entity:set_can_traverse_ground("deep_water", true)
  entity:set_can_traverse_ground("shallow_water", true)
  entity:set_can_traverse_ground("low_wall", true)
  entity:set_can_traverse_ground("lava", true)
  entity:set_can_traverse_ground("prickles", true)

  local m=sol.movement.create("straight")
  m:set_speed(192)
  m:set_angle(entity:get_sprite():get_direction()*math.pi/2)
  m:set_smooth(false)
  m.on_obstacle_reached=function()
    --TODO find a way to ignore axisting explosions
    --Will it explode on it's own ? no :(
    local x,y,layer=entity:get_position()
    audio_manager:play_entity_sound(entity,"items/bomb_explode")
    map:create_explosion({
        x=x, 
        y=y,
        layer=layer,
      })
    entity:remove()
  end
  m:start(entity)

end

local state=sol.state.create("bonking")
state:set_can_control_movement(false)
state:set_can_control_direction(false)
local audio_manager=require("scripts/audio_manager")
local jump_manager=require("scripts/maps/jump_manager")

local hero_meta=sol.main.get_metatable ("hero")

function hero_meta:bonk()

  if not self:is_custom_state_started("bonking") then

    self:start_state(state)
  end
end

function state:on_started()
  local movement=sol.movement.create("straight")

  local entity=state:get_entity()
  movement:set_speed(88)
  movement:set_angle((entity:get_direction()+2)*math.pi/2)
  function movement:on_position_changed()
    if entity:is_running() then
      entity.running = false
    end
  end
  --Bonk !
  if entity:get_sprite("trail") then
    entity:get_sprite("trail"):stop_animation()
  end
  entity.bonking=true
  --state:set_can_control_movement(false)
  audio_manager:play_sound("hero/running_obstacle")

  local map=entity:get_map()

  --Crash into entities (imported from the original custom script, don't know if it even works) 
  for other in map:get_entities_in_rectangle(entity:get_bounding_box()) do
    if entity:overlaps(other, "facing") then
      if other.on_boots_crash ~= nil then
        other:on_boots_crash()
      end
    end
  end

  --Shake the camera, unless it is already shaking to not stop it too early during map animations.
  --Note, the current implementation of the shake function was intended to be used on static screens, so until it's reworked, there will be some visual mishaps at the end of the effect (the camera will abruptly go back to the the hero)
  local camera = map:get_camera()
  if not camera:is_shaking() then
    camera:dynamic_shake({count = 50, amplitude = 2, speed = 90, entity=entity})
  end

  --Play funny animation
  local collapse_sprite=entity:get_sprite("tunic"):set_animation("hurt")
  local sword_sprite=entity:get_sprite("running_sword")
  if sword_sprite then
    entity:remove_sprite(sword_sprite)
  end
  local shield = state:get_game():get_item("shield_hero") or state:get_game():get_item("shield_hylia") or state:get_game():get_item("shield_mirror")
  if shield:is_being_used() then
    shield:stop_using()
  end
    jump_manager.start_parabola(entity, 2, function()
        entity.bonking=nil
        audio_manager:play_sound("hero_lands")
        entity:unfreeze()
        local ground=entity:get_ground_below()
        if not (ground=="hole" or ground=="lava" or ground=="deep_water") then
          entity:get_sprite():set_animation("stopped")
        end
      end)
  entity:get_sprite():set_animation("hurt")
  function movement:on_obstacle_reached()
    --Reverse bonking direction
    --audio_manager:play_sound("hero/land")
    movement:set_speed(88)
    movement:set_angle(movement:get_angle()+math.pi)
  end
  movement:start(entity)

  -- Call on_bonking event.
  if entity.on_bonking then
    entity:on_bonking()
  end
end

return function(_jump_manager)
  jump_manager=_jump_manager
end
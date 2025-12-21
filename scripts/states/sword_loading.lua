

--[[
  Top-view custom jump with sword being loaded.

  To use, simply require this file into your jump-enabling item script, then call hero:start_jumping()
  Note, this script only handles (for now?) jumping with the sword being simultaneously being used (unless the item scripts handles this case on it's own).
  Don't forget to require "states/jumping" along this file so you can jump with bare hands too.

  This script is mostly a wrapper, all this does is setup the custom state and pass it to the jump manager system, who will actually do the animation.
--]]

local sword_manager
local audio_manager=require("scripts/audio_manager")

local state = sol.state.create("sword_loading")
state:set_can_use_item(false)
state:set_can_use_item("sword", true)
state:set_can_use_item("shield", true)
state:set_can_use_item("feather", true)
state:set_can_use_item("rod_fire", true)
state:set_can_cut(false)
state:set_can_push(false)
state:set_can_control_movement(true)
state:set_can_control_direction(false)
state:set_can_traverse("stairs", false)

local hero_meta= sol.main.get_metatable("hero")

--this is the function that starts it all
function hero_meta.sword_loading(hero)
  --print "attack on air !"
  if hero:get_state()~="custom" or hero:get_state_object():get_description()~="sword_loading" then
    hero:start_state(state)
  end
end


function state:on_started(old_state_name, old_state_object)
  state:set_affected_by_ground("deep_water", (not state:get_map():is_sideview() or state:get_game():get_item("flippers"):get_variant()==0))

  debug_print ("going from "..old_state_name..(old_state_object and "("..old_state_object:get_description()..")" or "").." to custom sword loading")
  local entity=state:get_entity()
  local game = state:get_game()
  --Set up sprites
  local tunic_sprite = entity:get_sprite("tunic")
  local sword_sprite = entity:get_sprite("sword_override")
  local stars_sprite = entity:get_sprite("sword_stars_override")
  stars_sprite:set_direction(tunic_sprite:get_direction())
  if entity:get_movement() and entity:get_movement():get_speed()>0 then
    tunic_sprite:set_animation("sword_loading_walking")
    sword_sprite:set_animation("sword_loading_walking")   
  else
    tunic_sprite:set_animation("sword_loading_stopped")
    sword_sprite:set_animation("sword_loading_stopped")
  end
  stars_sprite:set_animation("loading")
  if entity.sword_loaded then
    tunic_sprite:set_frame(tunic_sprite:get_num_frames()-1)
    sword_sprite:set_frame(sword_sprite:get_num_frames()-1) 
    stars_sprite:set_frame(stars_sprite:get_num_frames()-1) 
  end
  sol.timer.start(state, 100, function()
      local _left=game:is_command_pressed("left") and -1 or 0
      local _right=game:is_command_pressed("right") and 1 or 0
      local _up=game:is_command_pressed("up") and -1 or 0
      local _down=game:is_command_pressed("down") and 1 or 0
      if not entity:is_jumping()  then
        local dx=_up + _down
        local dy=_left+_right
        local direction=game:get_commands_direction()
        --print "step 1 OK"
        if direction==tunic_sprite:get_direction()*2 and (dx ~= 0 or dy ~= 0) and entity:test_obstacles(_left+_right, _up+_down) then
          debug_print "sword tapping conditions OK"
          sword_manager.trigger_event(entity, "sword tapping")
        end
      end
      return true
    end)
  sol.timer.start(state, 1000, function()
      entity.sword_loaded=true
      audio_manager:play_sound("items/sword_charge")
    end)

end

function state:on_movement_changed(movement)
  local entity=state:get_entity()
  local tunic_sprite = entity:get_sprite("tunic")
  local sword_sprite = entity:get_sprite("sword_override")
  if movement.get_speed and movement:get_speed()>0 then
    tunic_sprite:set_animation("sword_loading_walking")
    sword_sprite:set_animation("sword_loading_walking")   
  else
    tunic_sprite:set_animation("sword_loading_stopped")
    sword_sprite:set_animation("sword_loading_stopped")
  end
end

function state:on_command_released(command)
  if command=="attack" then
    sword_manager.trigger_event(state:get_entity(), "attack command released")  
    return true
  end
end

function state:on_finished()
  debug_print "fishing sword loading state"
  local entity=state:get_entity()
  entity:get_sprite("sword_stars_override"):stop_animation()
  entity:get_sprite("sword_override"):stop_animation()
end

return function(_sword_manager)
  sword_manager=_sword_manager
end


--[[
  Top-view custom jump with sword tapping against an obstacle.

  To use, simply require this file into your jump-enabling item script, then call hero:start_jumping()
  Note, this script only handles (for now?) jumping with the sword being simultaneously being used (unless the item scripts handles this case on it's own).
  Don't forget to require "states/jumping" along this file so you can jump with bare hands too.

  This script is mostly a wrapper, all this does is setup the custom state and pass it to the jump manager system, who will actually do the animation.
--]]

local sword_manager
local audio_manager=require("scripts/audio_manager")

local state = sol.state.create("sword_tapping")
state:set_can_use_item(false)
state:set_can_use_item("sword", true)
state:set_can_use_item("shield", true)
state:set_can_cut(true) --TODO refine me
state:set_can_control_movement(false)
state:set_can_control_direction(false)


local hero_meta= sol.main.get_metatable("hero")
local sword_sprite
local tunic_sprite
local stars_sprite

--this is the function that starts it all
function hero_meta.sword_tapping(hero)
  --print "attack on air !"
  if hero:get_state()~="custom" or hero:get_state_object():get_description()~="sword_tapping" then
    hero:start_state(state)
  end
end


function state:on_started(old_state_name, old_state_object)
    debug_print ("going from "..old_state_name..(old_state_object and "("..old_state_object:get_description()..")" or "").." to custom sword tapping")
--print "flying attaaaaack"
  local entity=state:get_entity()
  local game = state:get_game()
  --Set up sprites
  tunic_sprite = entity:get_sprite("tunic")
  sword_sprite = entity:get_sprite("sword_override")
  stars_sprite = entity:get_sprite("sword_stars_override")
  tunic_sprite:set_animation("sword_tapping")
  sword_sprite:set_animation("sword_tapping")
  sol.timer.start(state, tunic_sprite:get_num_frames()*tunic_sprite:get_frame_delay(), function()
      sword_manager.trigger_event(entity, "sword tapping over")
    end)
end

function state:on_command_released(command)
  if command=="attack" then
    sword_manager.trigger_event(state:get_entity(), "attack command released")  
    return true
  end
end

function state:on_finished()
  sword_sprite:stop_animation()
  stars_sprite:stop_animation()
end

return function(_sword_manager)
  sword_manager=_sword_manager
end
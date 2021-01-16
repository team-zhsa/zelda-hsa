--[[
  Top-view custom jump while performing a spin attack.

  To use, simply require this file into your jump-enabling item script, then call hero:start_jumping()
  Note, this script only handles (for now?) jumping with the sword being simultaneously being used (unless the item scripts handles this case on it's own).
  Don't forget to require "states/jumping" along this file so you can jump with bare hands too.

  This script is mostly a wrapper, all this does is setup the custom state and pass it to the jump manager system, who will actually do the animation.
--]]

local sword_manager
--local audio_manager=require("scripts/audio_manager")
local state = sol.state.create("sword_spin_attack")
state:set_can_use_item(false)
state:set_can_cut(true) --TODO refine me
state:set_can_control_movement(true)
state:set_can_control_direction(false)
local hero_meta= sol.main.get_metatable("hero")
local sword_sprite
local tunic_sprite


--this is the function that starts it all
function hero_meta.sword_spin_attack(hero)
  --print "attack on air !"
  if hero:get_state()~="custom" or hero:get_state_object():get_description()~="sword_spin_attack" then
    hero:start_state(state)
  end
end


function state:on_started(old_state_name, old_state_object)
    debug_print ("going from "..old_state_name..(old_state_object and "("..old_state_object:get_description()..")" or "").." to custom sword spin attack")
--print "flying attaaaaack"
  local entity=state:get_entity()
  local game = state:get_game()

  --Set up sprites
  tunic_sprite = entity:get_sprite("tunic")
  sword_sprite = entity:get_sprite("sword_override")

  sword_sprite:set_direction(tunic_sprite:get_direction())
  tunic_sprite:set_animation("spin_attack", function()
      sword_manager.trigger_event(entity, "sword spin attack complete")
    end)
  sword_sprite:set_animation("spin_attack")
end

function state:on_finished()
  sword_sprite:stop_animation()
  sword_sprite = nil
end

return function(_sword_manager)
  sword_manager=_sword_manager
end
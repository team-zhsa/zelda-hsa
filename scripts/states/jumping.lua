--[[

  Newer version of the top-view custom jump, allows for the sword to be used mid-air.

  To use, simply require this file into your jump-enabling item script, then call hero:start_jumping()
  Note, this script only handles (for now?) jumping with no item being simultaneously being used (unless the item scripts handles this case on it's own). If you want to be able to use the sword while jumping, then require "states/jumping_sword" too.
  
--]]

local audio_manager=require("scripts/audio_manager")
local jump_manager
local state = sol.state.create("jumping")
state:set_can_use_item(false)
state:set_can_use_item("sword", true)
state:set_can_use_item("shield_hero", true)
state:set_can_use_item("shield_hylia", true)
state:set_can_use_item("shield_mirror", true)
state:set_can_cut(false) --TODO refine me
state:set_can_control_movement(true)
state:set_can_control_direction(false)
state:set_can_traverse("stairs", false)

function state:on_started(previous_state_name, previous_state_object)

  local map = state:get_map()
  local entity = state:get_entity()
  local x,y,layer = entity:get_position() 
  local bx, by, bh, bw=entity:get_bounding_box()
--  if entity:get_movement():get_speed()~=0 then
--Same bug as the ground-sound playing routine: for some reason, the movement's speed registers as 0 even if we are moving, so we never trigger the jumping animation.
    entity:get_sprite("tunic"):set_animation("jumping")
--  end

end


local hero_meta=sol.main.get_metatable("hero")

--This is the function that starts the whole jumping process
function hero_meta.jump(hero)

  --Safety check: if we are not already in this state then start it
  if hero:get_state() ~= "custom" or hero:get_state_object():get_description()~="jumping" then
    hero:start_state(state)
  end
end

return function(_jump_manager)
  jump_manager=_jump_manager
end
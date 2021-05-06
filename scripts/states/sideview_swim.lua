local state = sol.state.create("sideview_swim")
state:set_can_use_sword(true)
state:set_can_use_item(false)
state:set_can_use_item("feather", true)
state:set_can_use_item("hookshot", true)
state:set_can_control_movement(true)
state:set_can_control_direction(true)

local hero_meta=sol.main.get_metatable("hero")
function hero_meta:start_swimming()
  if self:get_state()~="custom" or self:get_state_object():get_description()~="sideview_swim" then
    self:start_state(state)
  end
end

function state:on_position_changed(x,y,layer)
  -- debug_print "i'm swiiiiiiiming in the poool, just swiiiiiming in the pool"
  local entity=state:get_entity()
  local map = state:get_map()
  if map:get_ground(x,y,layer)~="deep_water" then
    entity:unfreeze()
  end
end
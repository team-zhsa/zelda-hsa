local pickable_meta=sol.main.get_metatable("pickable")
local entity_manager= require("scripts/maps/entity_manager")
require "scripts/multi_events"

pickable_meta:register_event("on_removed", function(pickable)
    
  local item=pickable:get_treasure()
  local name = item:get_name()
  if name=="small_key" or name=="angler_key" or name=="red_key" or name=="blue_key" or name=="yellow_key" or name=="green_key"then
    local ground=pickable:get_ground_below()
    if ground=="hole" then
      entity_manager:create_falling_entity(pickable)
    end
  end
  
end)
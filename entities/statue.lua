local entity = ...

-- Include scripts
require("scripts/multi_events")

-- Event called when the custom entity is initialised.
entity:register_event("on_created", function()
  
  entity:set_traversable_by(false)
  entity:set_drawn_in_y_order(true)

end)
-- Variables
local entity = ...
local game = entity:get_game()
local map = entity:get_map()

-- Include scripts
require("scripts/multi_events")

-- Event called when the custom entity is initialised.
entity:register_event("on_created", function()
  
  entity:set_traversable_by(false)

end)

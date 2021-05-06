-- Variables
local entity = ...
local game = entity:get_game()
local map = entity:get_map()

-- Include scripts
require("scripts/multi_events")

-- Event called when the custom entity is initialized.
entity:register_event("on_created", function()

  entity:set_traversable_by("hero", false)
  entity:set_drawn_in_y_order(true)

end)
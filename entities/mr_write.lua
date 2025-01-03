-- Lua script of custom entity mr_write.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()

-- Event called when the custom entity is initialised.
function entity:on_created()

  entity:set_traversable_by("hero", false)
  entity:set_drawn_in_y_order(true)

end

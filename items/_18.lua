-- Lua script of item wings.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()

-- Event called when all items have been created.
function item:on_started()
  
end

-- Event called when the hero starts using this item.
function item:on_using()
  
  item:set_finished()
end


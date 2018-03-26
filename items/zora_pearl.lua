-- Lua script of item zora_pearl.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()

function item:on_created()

  self:set_savegame_variable("flippers_quest_zora_pearl")
  self:set_amount_savegame_variable("zora_pearl_counter")
  self:set_assignable(false)
end

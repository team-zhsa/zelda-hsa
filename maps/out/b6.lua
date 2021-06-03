-- Lua script of map out/b6.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local field_music_manager = require("scripts/maps/field_music_manager")

map:register_event("on_draw", function(map)

  -- Music
  field_music_manager:init(map)

end)

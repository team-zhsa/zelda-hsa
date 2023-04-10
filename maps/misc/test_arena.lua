-- Lua script of map misc/test_arena.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local flying_tile_manager = require("scripts/maps/flying_tile_manager")
-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
flying_tile_manager:init(map, "enemy_10")
flying_tile_manager:launch(map, "enemy_10")
  -- You can initialise the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

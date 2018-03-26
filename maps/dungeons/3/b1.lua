-- Lua script of map dungeon_3/b1.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  weak_door_1_c:set_enabled(false)
  weak_door_1_a:set_enabled(true)
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function weak_door_1_b:on_collision_explosion()
  weak_door_1_c:set_enabled(true)
  weak_door_1_a:set_enabled(false)
  game:set_dungeon_3_weak_door_1(true)
end
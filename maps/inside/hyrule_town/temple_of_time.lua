-- Lua script of map inside/hyrule_town/temple_of_time.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function master_sword:on_interaction()
  if game:get_value("dungeon_finish", 1) and game:get_value("dungeon_finish", 2) and game:get_value("dungeon_finish", 3) then
  hero:freeze()
  sol.timer.start(map, 1000
  end)
  end
end


-- Lua script of map outside/c5.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function weaks:on_collision_explosion()
  hero:freeze()
    sol.timer.start(500, function()
    sol.audio.play_sound("common/secret_discover_minor")
      weak_1:set_enabled(false)
      weak_2:set_enabled(false)
      weak_3:set_enabled(false)
      weak_4:set_enabled(false)
      weak_5:set_enabled(false)
      weak_6:set_enabled(false)
      hero:unfreeze()
    end)
end
-- Lua script of map dungeon_9/1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  heart_container:set_enabled(false)
  d9_fairy_sensor:set_enabled(true)
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function boss:on_dead()
  heart_container:set_enabled(true)
end

function mountain_power_sensor:on_activated()
  mountain_power_sensor:set_enabled(false)
  d9_fairy_sensor:set_enabled(true)
  game:set_value("mountains_power", 1)
  game:start_dialog("ocarina.chants.montagnes")
  sol.audio.play_sound("ocarina/montagne")
end

function d9_fairy_sensor:on_activated()
  game:get_max_life()
end
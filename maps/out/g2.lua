-- Lua script of map out/g2.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
-- Event called at initialization time, as soon as this map is loaded.
-- Map events
map:register_event("on_started", function(map, destination)

  -- Music
  init_music()

end)

-- Initialize the music of the map
function init_music()
  if game:get_value("time_of_day") == "day" then
    audio_manager:play_music("outside/overworld")
  elseif game:get_value("time_of_day") == "night" then
    audio_manager:play_music("outside/field_night")
  end

end


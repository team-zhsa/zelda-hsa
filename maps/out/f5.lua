-- Lua script of map outside/f5 
-- PS: Je vais me faire striker par Erdoğan :)
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
local audio_manager = require("scripts/audio_manager")
local field_music_manager = require("scripts/maps/field_music_manager")

map:register_event("on_draw", function(map)

  -- Music
  field_music_manager:init(map)

end)


-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function farm_door_s:on_activated()
  farm_door:remove()
end
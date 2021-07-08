-- Lua script of map outside/f6.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
local audio_manager = require("scripts/audio_manager")
local field_music_manager = require("scripts/maps/field_music_manager")

map:register_event("on_draw", function(map)

  -- Music
  field_music_manager:init(map)

end)

map:register_event("on_started", function()
	map:set_digging_allowed(true)
end)

--[[function woman_bush:on_lifting()
  sol.audio.play_sound("common/secret_discover_minor")
  woman_npc:set_enabled(true)
end

function woman_bush:on_cut()
  sol.audio.play_sound("common/secret_discover_minor")
  woman_npc:set_enabled(true)
end
function woman_bush:on_exploded()
  sol.audio.play_sound("common/secret_discover_minor")
  woman_npc:set_enabled(true)
end

function woman_npc:on_interaction()
  game:start_dialog("maps.field.f6.woman")
end--]]
-- Lua script of map outside/f6.
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

function woman_bush:on_lifting()
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
end
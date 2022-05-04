-- Lua script of map inside/houses/kakarico/bar_1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

npc_drunk_man:register_event("on_interaction", function()
  if game:get_value("possession_flippers") == 0 then
    game:start_dialog("maps.houses.kakarico_village.milk_bar.drunk_man_1")
  else
    game:start_dialog("maps.houses.kakarico_village.milk_bar.drunk_man_2")
  end
end)


function door_stairs:on_opened()
	sol.audio.play_sound("common/secret_discover_minor")
end
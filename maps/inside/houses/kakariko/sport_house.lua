-- Lua script of map inside/houses/kakarico/windmil_1fl.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	gate:set_enabled(true)
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function npc_sport:on_interaction()
	game:start_dialog("maps.houses.kakarico_village.sport_house.ask", function(answer)
		if answer == 1 then
			  game:start_dialog("maps.houses.kakarico_village.sport_house.yes")
				gate:set_enabled(false)
		end
	end)
end
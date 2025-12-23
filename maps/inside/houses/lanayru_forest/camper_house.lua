-- Lua script of map inside/houses/lanayru_forest/camper_house.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()

	-- You can initialise the movement and sprites of various
	-- map entities here.
end

npc_camper:register_event("on_interaction", function()
	if game:has_item("pegasus_boots") then
		game:start_dialog("maps.houses.lanayru_forest.camper_house.lonlon_ranch", game:get_player_name())
	else game:start_dialog("maps.houses.lanayru_forest.camper_house.gerudo_training_grounds", game:get_player_name())
	end
end)

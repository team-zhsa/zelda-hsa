-- Lua script of map inside/houses/south_castle/lavios_house.
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

function sensor_welcome:on_activated()
	game:start_dialog("maps.houses.south_castle.ravios_shop.merchant_welcome", game:get_player_name())
	sensor_welcome:remove()
end

function npc_ravio:on_interaction()
	game:start_dialog("maps.houses.south_castle.ravios_shop.merchant_welcome", game:get_player_name())
end
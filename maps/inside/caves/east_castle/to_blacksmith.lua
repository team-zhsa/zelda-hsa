-- Lua script of map inside/caves/east_castle/to_blacksmith.
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

function sensor_shop_welcome_1:on_activated()
	game:start_dialog("maps.caves.east_castle.to_blacksmith_shop.merchant_welcome")
	sensor_shop_welcome_1:remove()
	sensor_shop_welcome_2:remove()
end

function sensor_shop_welcome_2:on_activated()
	game:start_dialog("maps.caves.east_castle.to_blacksmith_shop.merchant_welcome")
	sensor_shop_welcome_1:remove()
	sensor_shop_welcome_2:remove()
end

function npc_merchant:on_interaction()
	game:start_dialog("maps.houses.south_castle.ravios_shop.merchant_welcome")
end
-- Lua script of map inside/houses/cordinia/white_hut.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

function sensor_shop_welcome:on_activated()
  game:start_dialog("maps.houses.cordinia_town.potion_shop.merchant_welcome", function()
    game:set_life(game:get_max_life())
  end)
  sensor_shop_welcome:remove()
end

function merchant:on_interaction()
  game:start_dialog("maps.houses.cordinia_town.potion_shop.merchant_welcome")
end
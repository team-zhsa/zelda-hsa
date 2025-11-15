-- Lua script of map inside/caves/east_mountains/shop.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

npc_merchant:register_event("on_interaction", function()
  game:start_dialog("maps.caves.east_mountains.shop.merchant_welcome")
end)

sensor_shop_welcome:register_event("on_activated", function()
  game:start_dialog("maps.caves.east_mountains.shop.merchant_welcome", function()
    sensor_shop_welcome:remove()
  end)
end)
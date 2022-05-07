-- Lua script of map inside/houses/kakariko/mapper_shop.
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

function sensor_shop_welcome:on_activated()
  if game:is_step_last("sword_obtained") then
    game:start_dialog("maps.houses.kakarico_village.mapper_shop.merchant_welcome_sale")
    sensor_shop_welcome:remove()
  else
    game:start_dialog("maps.houses.kakarico_village.mapper_shop.merchant_welcome")
    sensor_shop_welcome:remove()
  end
end

function merchant:on_interaction()
  if game:is_step_last("sword_obtained") then
    game:start_dialog("maps.houses.kakarico_village.mapper_shop.merchant_welcome_sale")
  else
    game:start_dialog("maps.houses.kakarico_village.mapper_shop.merchant_welcome")
  end
end
local map = ...
local game = map:get_game()

function sensor_shop_welcome:on_activated()
  game:start_dialog("maps.houses.snowpeaks.shop.merchant_welcome")
  sensor_shop_welcome:remove()
end

function merchant:on_interaction()
  game:start_dialog("maps.houses.snowpeaks.shop.merchant_welcome")
end
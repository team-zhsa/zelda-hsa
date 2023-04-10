-- Lua script of map inside/houses/east_castle/blacksmith.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	blacksmith_1:get_sprite():set_animation("hammer")
	blacksmith_2:get_sprite():set_animation("hammer")
  -- You can initialise the movement and sprites of various
  -- map entities here.
end

blacksmith_dialog:register_event("on_interaction", function()
  blacksmith_interaction()
end)

blacksmith_dialog_2:register_event("on_interaction", function()
  blacksmith_interaction()
end)

blacksmith_dialog_3:register_event("on_interaction", function()
  blacksmith_interaction()
end)

blacksmith_dialog_4:register_event("on_interaction", function()
  blacksmith_interaction()
end)

function sensor_shop_welcome:on_activated()
  game:start_dialog("maps.houses.east_castle.blacksmith.merchant_welcome")
  sensor_shop_welcome:remove()
end

function sensor_welcome:on_activated()
  game:start_dialog("maps.houses.east_castle.blacksmith.welcome")
  sensor_shop_welcome:remove()
end

function blacksmith_interaction()
  if game:is_step_last("lamp_obtained") then
    game:start_dialog("maps.houses.east_castle.blacksmith.offer_sword", function()
      hero:start_treasure("sword", 1)
      game:set_step_done("sword_obtained")
    end)
  elseif game:is_step_done("dungeon_7_completed") and game:get_item("sword"):get_variant(2) then
    game:start_dialog("maps.houses.east_castle.blacksmith.sword_upgrade_offer", function(answer)
      if answer == 1 then
        game:start_dialog("maps.houses.east_castle.blacksmith.sword_yes", function()
          game:get_item("sword"):set_variant(0)
          game:set_value("sword_being_upgraded", true)
        end)
      else game:start_dialog("maps.houses.east_castle.blacksmith.sword_no")
      end
    end)
  elseif game:get_value("sword_being_upgraded", true) then
    game:start_dialog("maps.houses.east_castle.blacksmith.sword_upgrade_not_ready")
  end
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

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
  -- You can initialize the movement and sprites of various
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


function blacksmith_interaction()
  if game:is_step_last("game_started") then
    game:start_dialog("maps.houses.east_castle.blacksmith.merchant_sahasrahla", function()
      hero:start_treasure("sword", 1)
      game:set_step_done("sword_obtained")
    end)
  end
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

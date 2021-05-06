-- Lua script of map houses/main_town/building_a.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local house_manager = require("scripts/maps/house_manager")

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	house_manager:init(map)
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function sleep_npc:on_interaction()
  game:start_dialog("maps.houses.hyrule_town.building.sleep", function(answer)
    if answer==2 then
      if game:get_money() >=20 then
        game:remove_money(20)
        game:add_life(120)
        game:add_magic(500)
      else
        game:start_dialog("_shop.not_enough_money")
        game:add_life(0)
        game:add_magic(0)
      end
    elseif answer==3 then
      game:add_life(0)
      game:add_magic(0)
    end
  end)
end
  
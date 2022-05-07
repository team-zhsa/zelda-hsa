-- Lua script of map houses/main_town/quest_potion_house.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  game:start_dialog("maps.houses.hyrule_town.sword.0")
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function npc_sword:on_interaction()
  if game:get_value("main_quest", 2) then
    game:start_dialog("maps.houses.hyrule_town.sword.1", function()
      hero:start_treasure("sword", 1)
      game:set_value("main_quest", 3)
    end)
  end
end
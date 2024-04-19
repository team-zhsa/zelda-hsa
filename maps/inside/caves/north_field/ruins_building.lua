-- Lua script of map inside/caves/north_west/ruins_building.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local minigame_manager = require("scripts/maps/minigame_manager")

npc_marathon:register_event("on_interaction", function()
  if not minigame_manager:is_playing(map, marathon) == true then
    if not game:is_step_done("dungeon_1_completed") then
      -- Bridge closed
      game:start_dialog("maps.caves.north_field.marathon_man.marathon_bridge_closed")
    else
      if not game:has_item("pegasus_boots") then
        -- No Pegasus Boots
        game:start_dialog("maps.caves.north_field.marathon_man.marathon_no_shoes")
      else game:start_dialog("maps.caves.north_field.marathon_man.marathon_question", function(answer)
        if answer == 1 and game:get_money() >= 60 then
          -- Start the game.
          game:start_dialog("maps.caves.north_field.marathon_man.marathon_yes", function()
            minigame_manager:start_minigame(map, marathon)
          end)
        elseif answer == 1 and game:get_money() < 60 then
          game:start_dialog("_shop.not_enough_money")
        elseif answer == 2 then
          game:start_dialog("maps.caves.north_field.marathon_man.marathon_no")
        end
      end)
      end
    end
  else minigame_manager:end_minigame(map, marathon); print(game:get_value(minigame.."_minigame_previous_time"))
  end
    
end)
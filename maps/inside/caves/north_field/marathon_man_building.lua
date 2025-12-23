-- Lua script of map inside/caves/north_west/ruins_building.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local minigame_manager = require("scripts/maps/minigame_manager")
local time_limit = 240

npc_marathon:register_event("on_interaction", function()
  local function play_question()
    game:start_dialog("maps.caves.north_field.marathon_man.marathon_question", function(answer)
      if answer == 1 and game:get_money() >= 90 then
        -- Start the game.

        if not game:get_value("outside_marathon_minigame_piece_of_heart")
        and not game:get_value("outside_marathon_minigame_rupees") then
          time_limit = 240
        elseif not game:get_value("outside_marathon_minigame_rupees") then
          time_limit = 210
        else time_limit = game:get_value("marathon_minigame_record_time")
        end

        local total_seconds = time_limit
        local seconds = total_seconds % 60
        local total_minutes = math.floor(total_seconds / 60)
        local minutes = total_minutes % 60
        local time_limit_str = string.format("%02d:%02d", total_minutes, seconds)

        game:start_dialog("maps.caves.north_field.marathon_man.marathon_yes",
        time_limit_str, function()
          minigame_manager:start_marathon(map, total_seconds)
          game:remove_money(90)
        end)

      elseif answer == 1 and game:get_money() < 90 then
        game:start_dialog("_shop.not_enough_money")

      elseif answer == 2 then
        game:start_dialog("maps.caves.north_field.marathon_man.marathon_no")
      end
    end)
  end

  if not minigame_manager:is_playing(map, "marathon") == true then
    if not game:is_step_done("dungeon_1_completed") then
      -- Bridge closed
      game:start_dialog("maps.caves.north_field.marathon_man.marathon_bridge_closed")
    else
      if not game:has_item("pegasus_boots") then
        -- No Pegasus Boots
        game:start_dialog("maps.caves.north_field.marathon_man.marathon_no_shoes")
      
      else
        game:start_dialog("maps.caves.north_field.marathon_man.marathon_intro", function()
          if game:get_value("marathon_minigame_record_time") ~= nil then

            local total_seconds = game:get_value("marathon_minigame_record_time")
            local seconds = total_seconds % 60
            local total_minutes = math.floor(total_seconds / 60)
            local minutes = total_minutes % 60
            local record_time = string.format("%02d:%02d", minutes, seconds)

            game:start_dialog("maps.caves.north_field.marathon_man.marathon_previous_record",
            record_time, function()
              play_question()
            end)
          else play_question() end
        end)
      end
    end
  else  game:start_dialog("maps.caves.north_field.marathon_man.marathon_already_playing")
  end
    
end)
-- Lua script of map out/f5.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started() 
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

--On butter quest npc interaction
function npc_4:on_interaction()
--Get if player have begun this quest
  if game:get_value("quest_butter", 0) then
    game:start_dialog("quest.butter.need_butter", function(answer)
      if answer == 2 then
        game:start_dialog("quest.butter.yes")
        game:set_value("quest_butter", 1)
      else
        game:start_dialog("quest.butter.no")
      end
    end)
  end
end

function main_quest_s:on_activated()
  if game:get_value("main_quest", 1) then
    game:start_dialog("main_quest.step_2", function()
      game:set_value("main_quest", 2)
    end)
  end
end
    
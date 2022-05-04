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

map:register_event("on_started", function()
	game:show_map_name("hyrule_town")
	map:set_digging_allowed(true)
  if game:is_step_done("priest_met") then
    town_gate:set_enabled(false)
  end
end)

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
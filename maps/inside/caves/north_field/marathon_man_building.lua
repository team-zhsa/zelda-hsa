-- Lua script of map inside/caves/north_west/ruins_building.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

npc_marathon:register_event("on_interaction", function()
  -- Bridge closed
  if not game:is_step_done("dungeon_1_completed") then
    game:start_dialog("maps.out.north_field.marathon_man.marathon_bridge_closed")
  else
    if not game:has_item("pegasus_shoes") then
      game:start_dialog("maps.out.north_field.marathon_man.marathon_bridge_bridge_closed")
    end
  end
    
end)
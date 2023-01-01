-- Lua script of map houses/main_town/quest_potion_house.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
end)

npc_lost_woods_mapper:register_event("on_interaction", function()
  if game:is_step_last("dungeon_1_completed") then
    game:start_dialog("maps.houses.south_field.lost_woods_mapper.mapper_search_pendant", function()
      npc_directions()
    end)
  else
    game:start_dialog("maps.houses.south_field.lost_woods_mapper.mapper_welcome", game:get_player_name(), function()
      npc_directions()
    end)
  end
end)

function npc_directions()
  sol.timer.start(map, 200, function()
    game:start_dialog("maps.houses.south_field.lost_woods_mapper.mapper_directions", function(answer)
      if answer == 1 then
        game:start_dialog("maps.houses.south_field.lost_woods_mapper.mapper_sacred_grove")
      else game:start_dialog("maps.houses.south_field.lost_woods_mapper.mapper_kokiri")
      end
    end)
  end)
end
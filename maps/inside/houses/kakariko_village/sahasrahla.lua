-- Lua script of map inside/houses/kakarico/sahasrahla.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

sahasrahla:register_event("on_interaction", function()
  if game:is_step_last("sword_obtained") then
    game:start_dialog("maps.houses.kakarico_village.sahasrahla_house.sahasrahla_mapper", game:get_player_name())
  elseif game:is_step_last("world_map_obtained") then
    game:start_dialog("maps.houses.kakarico_village.sahasrahla_house.sahasrahla_has_world_map")
  elseif game:is_step_last("dungeon_1_completed") then
    lost_woods_map_dialog()
  else
    game:start_dialog("maps.houses.kakarico_village.sahasrahla_house.sahasrahla_sleep")
  end
end)

function lost_woods_map_dialog()
  game:start_dialog("maps.houses.kakarico_village.sahasrahla_house.sahasrahla_lost_woods_map", game:get_player_name(), function(answer)
    if answer == 1 then
      lost_woods_map_dialog()
    else game:set_step_done("sahasrahla_lost_woods_map")
    end
  end)
end
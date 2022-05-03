-- Lua script of map inside/houses/north_west/sanctuary.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  --if game:get_value("priest_kidnapped") == true then
    --sol.audio.play_music("inside/sanctuary_1")
    --priest:set_enabled(false)
  --else ---
    if game:get_time() >= 7 and game:get_time() < 15 and game:is_step_last("world_map_obtained") then
      sol.audio.play_music("inside/sanctuary_3")
      priest:set_enabled(true)
      door:set_enabled(true)
      dialog:set_enabled(true)
    else--if game:is_step_last("priest_kidnapped") then
      priest:set_enabled(false)
      door:set_enabled(false)
      dialog:set_enabled(false)
    end
  --end
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

dialog:register_event("on_interaction", function()
  if game:is_step_done("world_map_obtained") then
    hero:freeze()
    game:start_dialog("maps.houses.north_west.sanctuary.priest_1", function()
      sol.timer.start(map, 2000, function()
        tell_legend()
      end)
    end)
  
    
  else
  end
    
end)

function tell_legend()
  game:start_dialog("maps.houses.north_west.sanctuary.priest_2", function()
    sol.timer.start(map, 500, function()
      game:start_dialog("maps.houses.north_west.sanctuary.priest_3", function()
        sol.timer.start(map, 500, function()
          game:start_dialog("maps.houses.north_west.sanctuary.priest_4", game:get_player_name(), function(answer)
              if answer == 1 then
                tell_legend()
              else
                hero:unfreeze()
              end
          end)
        end)
      end)
    end)
  end)
end

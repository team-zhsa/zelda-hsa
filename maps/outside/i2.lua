-- Lua script of map out/i2.
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


-- Quand Link veut parler au Roi
function king_dialog_sensor:on_activated()
  if game:get_value("flippers_quest") == 0 then
  game:start_dialog("flippers_quest.0" answer function()
      if answer = 12 then
      game:start_dialog("flippers_quest.0.yes")
      elseif answer = 13 then
      game:start_dialog("flippers_quest.0.no")
      hero:teleport("out/f4")
      end
  elseif game:get_value("flippers_quest") == 1 then
  game:start_dialog("flippers_quest.1")
  hero:start_treasure("piece_of_heart", 1)
  end

end

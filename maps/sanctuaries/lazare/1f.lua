-- Lua script of map pic_lazare/1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  map:open_doors("miniboss_door")
  map:open_doors("enemy_door")
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

 -- Si tu marche sur miniboss sensor, miniboss door se ferme et se rouvre si miniboss meurt 

function door_miniboss:on_acivated()
  map:close_door("miniboss_door")
  remove:door_miniboss
end

function miniboss:on_dead()
  map:open_door("miniboss_door")
end

function enemy_sensor:on_acivated()
  map:close_door("enemy_door")
  remove:enemy_sensor
end

function enemy_door_2:on_dead()
  map:open_door("enemy")
end
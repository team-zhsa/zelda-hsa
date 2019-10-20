-- Lua script of map outside/a7.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

local function send_hero(from_sensor, to_sensor)
  local hero_x, hero_y = hero:get_position()
  local from_sensor_x, from_sensor_y = from_sensor:get_position()
  local to_sensor_x, to_sensor_y = to_sensor:get_position()

  hero_x = hero_x + to_sensor_x - from_sensor_x
  hero_y = hero_y + to_sensor_y - from_sensor_y
  hero:set_position(hero_x, hero_y)
end


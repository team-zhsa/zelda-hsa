-- Lua script of map dungeon_3/1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  map:open_doors("door_sensor_1_a")
  map:open_doors("door_sensor_2_a")
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end


for sensor in map:get_entities("weak_floor_") do
  function sensor:on_collision_explosion()  
  weak_floor:set_enabled(false)
  map:open_doors("weak_floor_door")
  sol.audio.play_sound("secret")
end
end

function door_switch_1_b:on_activated()
  map:open_doors("door_switch_1_a")
  map:open_doors("door_switch_2_a")
end

function door_sensor_1_b:on_activated()
  map:close_doors("door_sensor_1_a")
  door_sensor_1_b:set_enabled(false)
end

function door_sensor_1_c:on_dead()
  map:open_doors("door_sensor_1_a")
end

function door_sensor_2_b:on_activated()
  map:close_doors("door_sensor_2_a")
  door_sensor_2_b:set_enabled(false)
end

function door_sensor_2_c:on_dead()
  map:open_doors("door_sensor_2_a")
end

sol.timer.start(map, 1000, function()
  local num_calls = 0
  game:add_money(10)
   num_calls = num_calls + 1
  return num_calls < 120
end)
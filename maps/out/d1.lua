-- Lua script of map out/f1 - f2 - g1 - g2 - h1 - h2 - i1 - i2.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
	map:set_digging_allowed(true)
end)

-- Handle boulders spawning depending on activated sensor.
for sensor in map:get_entities("sensor_activate_boulder_") do
  sensor:register_event("on_activated", function(sensor)
    spawner_boulder_1:start()
    spawner_boulder_2:start()
		spawner_boulder_3:start()
		spawner_boulder_4:start()
  end)
end
for sensor in map:get_entities("sensor_deactivate_boulder_") do
  sensor:register_event("on_activated", function(sensor)
    spawner_boulder_1:stop()
    spawner_boulder_2:stop()
		spawner_boulder_3:stop()
		spawner_boulder_4:stop()
  end)
end
-- Lua script of map out/b1.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
	game:show_map_name("west_mountains")
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


-- Remove spawned boulders when too far of the mountain.
for spawner in map:get_entities("spawner_boulder_") do
  spawner:register_event("on_enemy_spawned", function(spawner, enemy)
    enemy:register_event("on_position_changed", function(enemy)
      local _, y, _ = enemy:get_position()
      if y > 2000 then
        enemy:remove()
      end
    end)
  end)
end

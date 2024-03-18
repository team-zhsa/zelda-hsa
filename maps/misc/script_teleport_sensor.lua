--This in map script

local function teleport_sensor(to_sensor, from_sensor)
  local hero_x, hero_y = hero:get_position()
  local to_sensor_x, to_sensor_y = to_sensor:get_position()
  local from_sensor_x, from_sensor_y = from_sensor:get_position()
 
  hero:set_position(hero_x - from_sensor_x + to_sensor_x, hero_y - from_sensor_y + to_sensor_y)
end
 
function sensor_corridor_from_13:on_activated()
  teleport_sensor(sensor_corridor_to_13, self)
end

function sensor_corridor_from_13_2:on_activated()
  teleport_sensor(sensor_corridor_to_13, self)
end
 
function sensor_corridor_from_25:on_activated()
  teleport_sensor(sensor_corridor_to_25, self)
	sol.audio.play_sound("common/secret_discover_minor")
end
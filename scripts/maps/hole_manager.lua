local hole_manager = {}

function hole_manager:enable_a_tiles(map, sound)
  local game = map:get_game()
  local dungeon_index = game:get_dungeon_index()
  for room = 1, 100 do
    for sensor in map:get_entities("sensor_"..room.."_floor_a_") do
    sensor:set_enabled(true)
    end
    for tile in map:get_entities("tile_"..room.."_switch_a_") do
      tile:set_enabled(true)
    end
    for tile in map:get_entities("tile_"..room.."_floor_a_") do
      tile:set_enabled(true)
    end
    for sensor in map:get_entities("sensor_"..room.."_floor_b_") do
      sensor:set_enabled(false)
    end
    for tile in map:get_entities("tile_"..room.."_switch_b_") do
      tile:set_enabled(false)
    end
    for tile in map:get_entities("tile_"..room.."_floor_b_") do
      tile:set_enabled(false)
    end
  end
  game:set_value("dungeon_"..dungeon_index.."_hole_state", a)
  if sound ~= nil then
    sol.audio.play_sound(sound)
  end
end

function hole_manager:enable_b_tiles(map, sound)
  local game = map:get_game()
  local dungeon_index = game:get_dungeon_index()
  for room = 1, 100 do
    for sensor in map:get_entities("sensor_"..room.."_floor_b_") do
      sensor:set_enabled(true)
    end
    for tile in map:get_entities("tile_"..room.."_switch_b_") do
      tile:set_enabled(true)
    end
    for tile in map:get_entities("tile_"..room.."_floor_b_") do
      tile:set_enabled(true)
    end
    for sensor in map:get_entities("sensor_"..room.."_floor_a_") do
      sensor:set_enabled(false)
    end
    for tile in map:get_entities("tile_"..room.."_switch_a_") do
      tile:set_enabled(false)
    end
    for tile in map:get_entities("tile_"..room.."_floor_a_") do
      tile:set_enabled(false)
    end
  end
  game:set_value("dungeon_"..dungeon_index.."_hole_state", b)
  if sound ~= nil then
    sol.audio.play_sound(sound)
  end
end

function hole_manager:switch_states(map)

  local game = map:get_game()
  local dungeon_index = game:get_dungeon_index()

  if game:get_value("dungeon_"..dungeon_index.."_hole_state", a) then
    hole_manager:enable_b_tiles()

  elseif game:get_value("dungeon_"..dungeon_index.."_hole_state") == a
  or game:get_value("dungeon_"..dungeon_index.."_hole_state") == nil then
    hole_manager:enable_a_tiles()
  end
end

return hole_manager
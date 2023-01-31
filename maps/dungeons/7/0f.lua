-- Variables
local map = ...
local game = map:get_game()

-- Include scripts
require("scripts/multi_events")
local audio_manager = require("scripts/audio_manager")
local door_manager = require("scripts/maps/door_manager")
local enemy_manager = require("scripts/maps/enemy_manager")
local separator_manager = require("scripts/maps/separator_manager")
local switch_manager = require("scripts/maps/switch_manager")
local treasure_manager = require("scripts/maps/treasure_manager")

-- Map events
map:register_event("on_started", function()

  -- Chests
  treasure_manager:disappear_chest(map, "chest_7_small_key")
  treasure_manager:disappear_chest(map, "chest_6_compass")
  treasure_manager:appear_chest_when_torches_lit(map, "torch_6_", "chest_6_compass")


  -- Doors
  map:set_doors_open("door_11_n", true)
  map:set_doors_open("door_11_e", true)
  map:set_doors_open("door_11_s", true)


  -- Enemies

  -- Music

  -- Pickables

  -- Separators
  separator_manager:manage_map(map)

end)

switch_7_chest:register_event("on_activated", function()
  treasure_manager:appear_chest(map, "chest_7_small_key")
end)

for sensor in map:get_entities("sensor_11_door_") do
  sensor:register_event("on_activated", function()
    map:close_doors("door_11_n")
    map:close_doors("door_11_e")
    map:close_doors("door_11_s")
  end)
end

for sensor in map:get_entities("sensor_11_sensor_") do
  -- Enables the sensors to close the doors
  sensor:register_event("on_activated", function()
    for sensor in map:get_entities("sensor_11_door_") do
      sensor:set_enabled(true)
    end
    switch_11_door:set_activated(false)
  end)
end

switch_11_door:register_event("on_activated", function()
  map:open_doors("door_11_n")
  map:open_doors("door_11_e")
  map:open_doors("door_11_s")
  -- Prevent doors from closing
  for sensor in map:get_entities("sensor_11_door_") do
    sensor:set_enabled(false)
  end
end)


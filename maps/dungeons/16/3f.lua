local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local door_manager = require("scripts/maps/door_manager")
local enemy_manager = require("scripts/maps/enemy_manager")
local separator_manager = require("scripts/maps/separator_manager")
local switch_manager = require("scripts/maps/switch_manager")
local treasure_manager = require("scripts/maps/treasure_manager")

map:register_event("on_started", function()
  separator_manager:manage_map(map)
  map:set_doors_open("door_1_e", true)
  map:set_doors_open("door_1_s", true)
  door_manager:open_when_enemies_dead(map, "enemy_1_", "door_1_e", sound)
  door_manager:open_when_enemies_dead(map, "enemy_1_", "door_1_s", sound)
end)

for sensor in map:get_entities("sensor_1_door_") do
  sensor:register_event("on_activated", function()
    map:close_doors("door_1_e")
    map:close_doors("door_1_s")
    sensor_1_door_1:remove()
    sensor_1_door_2:remove()
  end)
end
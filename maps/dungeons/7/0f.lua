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
  chest_7_small_key:set_enabled(false)
  -- Doors
  
  -- Enemies

  -- Music

  -- Pickables

  -- Separators
  separator_manager:manage_map(map)

end)

switch_7_chest:register_event("on_activated", function()
  treasure_manager:appear_chest(map, "chest_7_small_key")
end)
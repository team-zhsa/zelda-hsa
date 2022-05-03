-- Variables
local map = ...
local game = map:get_game()
local is_small_boss_active = false

-- Include scripts
require("scripts/multi_events")
local audio_manager = require("scripts/audio_manager")
local door_manager = require("scripts/maps/door_manager")
local enemy_manager = require("scripts/maps/enemy_manager")
local separator_manager = require("scripts/maps/separator_manager")
local switch_manager = require("scripts/maps/switch_manager")
local treasure_manager = require("scripts/maps/treasure_manager")
local is_boss_active = false
-- Map events


map:register_event("on_started", function()
	separator_manager:manage_map(map)
  door_manager:close_when_torches_unlit(map, "torch_12_door", "door_12_s")
  door_manager:open_when_torches_lit(map, "torch_12_door", "door_12_s")
  door_manager:open_when_torches_lit(map, "torch_28_door", "door_group_boss")
  enemy_manager:execute_when_vegas_dead(map, "enemy_22_small_key")
  treasure_manager:disappear_pickable(map, "small_key_22")
  treasure_manager:appear_pickable_when_enemies_dead(map, "enemy_22_small_key", "small_key_22")
	separator_manager:manage_map(map)
	if heart_container ~= nil then
		treasure_manager:disappear_pickable(map, "heart_container")
	end
end)

-- Boss events
if boss ~= nil then
	function sensor_boss:on_activated()
		map:close_doors("door_group_boss")
		sol.audio.play_music("boss/boss_albw")
		sensor_boss:remove()
	end

	function boss:on_dead()
		treasure_manager:appear_pickable(map, "heart_container")
		map:open_doors("door_group_boss")
	end
end

if pendant ~= nil then
	function map:on_obtained_treasure(item, variant, savegame_variable)
  	if item:get_name() == "pendant_2" then
      enemy_manager:start_completing_sequence(map)
      game:set_step_done("dungeon_2_completed")
    end
	end
end
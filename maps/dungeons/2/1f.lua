-- Lua script of map dungeons/2/1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local separator_manager = require("scripts/maps/separator_manager.lua")
local camera_meta = require("scripts/meta/camera.lua")

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	chest_20_blue_key:set_enabled(false)
	separator_manager:manage_map(map)
	game:start_dialog("maps.dungeons.2.welcome")
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function switch_28_1:on_activated()
  if switch_28_2:is_activated() and switch_28_3:is_activated() and switch_28_4:is_activated() then
    map:open_doors("door_27_n1")
    sol.audio.play_sound("common/secret_discover_minor")
  end
end

function switch_28_2:on_activated()
  if switch_28_1:is_activated() and switch_28_3:is_activated() and switch_28_4:is_activated() then
    map:open_doors("door_27_n1")
    sol.audio.play_sound("common/secret_discover_minor")
  end
end

function switch_28_3:on_activated()
  if switch_28_2:is_activated() and switch_28_1:is_activated() and switch_28_4:is_activated() then
    map:open_doors("door_27_n1")
    sol.audio.play_sound("common/secret_discover_minor")
  end
end

function switch_28_4:on_activated()
  if switch_28_2:is_activated() and switch_28_3:is_activated() and switch_28_1:is_activated() then
    map:open_doors("door_27_n1")
    sol.audio.play_sound("common/secret_discover_minor")
  end
end

function switch_20_chest:on_activated()
	chest_20_blue_key:set_enabled(true)
	game:set_value("dungeon_1_blue_key", 1)
end

function auto_block_2:on_moved()
	map:open_doors("door_19_w")
end

function auto_block_5:on_moved()
	map:open_doors("door_19_e")
end

function auto_block_8:on_moved()
	map:open_doors("door_19_s")
end

for npc in map:get_entities("magic_booth") do
	function magic_booth:on_interaction()
		if not game:get_value("dungeon_2_crossing_puzzle") then
			game:start_dialog("maps.dungeons.2.hint.arrows")
		elseif not game:get_value("dungeon_2_holes_puzzle") then
			game:start_dialog("maps.dungeons.2.hint.holes")
		elseif not game:get_value("dungeon_2_cyclop_puzzle") then
			game:start_dialog("maps.dungeons.2.hint.cyclop")
		end
	end
end

local life = game:get_max_life()
for custom_entity in map:get_entities("torch_10") do
	function custom_entity:on_lit()
		if math.random(1, 2) == 1 then
			game:remove_life(life / 2)
		else
			game:set_value("dungeon_2_1f_10_collapse_ground", true)
			dynamic_10_light:set_enabled(false)
			dynamic_10_collapse:set_enabled(false)
		end
	end
end

function sensor_4_collapse:on_collision_explosion()
	dynamic_4_collapse:set_enabled(false)
	sol.audio.play_sound("common/secret_discover_minor")
	game:set_value("dungeon_2_1f_4_collapse_ground", true)
end

function npc_fairy:on_interaction()
	game:start_dialog("scripts.meta.map.fairy", function()
		game:set_life(life)
	end)
end

function switch_13_wall:on_activated()
	dynamic_12_wall:set_enabled(false)
	dynamic_12_wall:set_enabled(true)
-- Lua script of map dungeons/2/1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	chest_20_blue_key:set_enabled(false)
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
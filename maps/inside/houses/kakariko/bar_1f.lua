-- Lua script of map inside/houses/kakarico/bar_1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	if game:get_value("kakarico_milk_bar_stairs_door", true) then
		  dynamic_stairs_door:set_enabled(false)
	else
		  dynamic_stairs_door:set_enabled(true)
	end
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end


function door_stairs:on_opened()
  dynamic_stairs_door:set_enabled(false)
	game:set_value("kakarico_milk_bar_stairs_door", true)
	sol.audio.play_sound("common/secret_discover_minor")
end
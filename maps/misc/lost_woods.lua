-- Lua script of map misc/lost_woods.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
tp_index = 0

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	if tp_index == 0 then
		tele_true:set_enabled(false)
	end
  -- You can initialise the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

for teletransporter in map:get_entities("tp_") do
	function teletransporter:on_activated()
		tp_index = tp_index + 1
		if tp_index >= 6 then
			teletransporter:set_enabled(false)
			tele_true:set_enabled(false)
		end
	end
end
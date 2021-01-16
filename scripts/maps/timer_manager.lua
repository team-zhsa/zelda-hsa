local timer_manager = {}
local game = map:get_game()
local hero = map:get_hero()
local time = 0
require("scripts/multi_events")

--[[ Small timer script for use with maps (dungeons)
Usage:
	- In map script, put:
		local timer_manager = require("Location of this script")--]]

function timer_manager:manage_map()
	sol.timer.start(map, time)
end
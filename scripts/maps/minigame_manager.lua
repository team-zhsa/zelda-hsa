--[[ Author: The Unknown, License: CC-BY-NC-SA
Usage: local minigame_manager = require("scripts/maps/minigame_manager")
Functions:

--]] 

local minigame_manager = {}
local timer_manager = require("scripts/maps/timer_manager")

-- Functions specific to each minigame.
function minigame_manager:start_marathon(map, time_limit)
	local game = map:get_game()
	minigame_manager:start_chronometer(map, "marathon", time_limit)
	minigame_manager:start_minigame(map, "marathon")
end

-- Standard functions for all minigames.

function minigame_manager:start_minigame(map, minigame)
	local game = map:get_game()
	local minigame_times_played = game:get_value(minigame.."_minigame_times_played") or 0
	game:set_value(minigame.."_minigame_playing", true)
	game:set_value(minigame.."_minigame_winning", false)
	game:set_value(minigame.."_minigame_time", 0)
	minigame_times_played = minigame_times_played + 1
	game:set_value(minigame.."_minigame_times_played", minigame_times_played)
end

function minigame_manager:start_chronometer(map, minigame, time_limit)
	local game = map:get_game()
	game:set_value(minigame.."_minigame_time_limit", time_limit)
	chrono_playing = true

	local time = 0 --game:get_value(minigame.."_minigame_time") or 512000
	timer_manager:start_timer(game, time_limit * 1000, "chronometer", true, true,
	function()
		if not game:get_value(minigame.."_minigame_winning", true) then
			minigame_manager:on_chronometer_timeout(map, minigame)
		end
	end,
	function()
		time = time + 1
		game:set_value(minigame.."_minigame_time", time)
	end)

end

function minigame_manager:on_chronometer_timeout(map, minigame)
	local game = map:get_game()
	if minigame == "marathon" then
		-- Set winning value to FALSE = losing.
		game:set_value(minigame.."_minigame_winning", false)
		minigame_manager:stop_minigame(map, minigame)
		sol.audio.play_sound("enemies/redead")
		game:start_dialog("maps.caves.north_field.marathon_man.marathon_timeout")
	end
end

function minigame_manager:stop_minigame(map, minigame)
	local game = map:get_game()
	
	if game:get_value(minigame.."_minigame_winning", true) then
		print("CONGRULATION OF WINNING GAME.."..minigame)
		--sol.audio.play_sound("common/prayer")
	else
		print("Minigame "..minigame.." has been lost.")
	end
	
	-- Set the record time.
	if game:get_value(minigame.."_minigame_record_time") == nil
	or (game:get_value(minigame.."_minigame_time") < game:get_value(minigame.."_minigame_record_time")) then
		game:set_value(minigame.."_minigame_record_time", game:get_value(minigame.."_minigame_time"))
	end
	
	if game:get_value(minigame.."_minigame_playing") then
		-- Stop playing.
		game:set_value(minigame.."_minigame_playing", false)
	else
		-- We are not even playing!
		print("Error: minigame "..minigame.." is not started.")
	end
end

function minigame_manager:end_minigame(map, minigame)
	local game = map:get_game()
	game:set_value(minigame.."_minigame_winning", true)
	chrono_playing = false
	minigame_manager:stop_minigame(map, minigame)
end

function minigame_manager:is_playing(map, minigame)
	local game = map:get_game()
	return game:get_value(minigame.."_minigame_playing")
end

return minigame_manager
--[[ Author: The Unknown, License: CC-BY-NC-SA
Usage: local minigame_manager = require("scripts/maps/minigame_manager")
Functions:

--]] 

local minigame_manager = {}
local timer_manager = require("scripts/maps/timer_manager")

-- Functions specific to each minigame.
function minigame_manager:start_marathon(map, time_limit)
	local game = map:get_game()
	minigame_manager:start_chronometer(map, "marathon", time_limit, "chronometer")
	minigame_manager:start_minigame(map, "marathon")
end

function minigame_manager:start_kakarico_maze(map, time_limit)
	local game = map:get_game()
	minigame_manager:start_chronometer(map, "kakarico_maze", time_limit, "countdown")
	minigame_manager:start_minigame(map, "kakarico_maze")
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

function minigame_manager:start_chronometer(map, minigame, time_limit, type)
	local game = map:get_game()
	game:set_value(minigame.."_minigame_time_limit", time_limit)
	chrono_playing = true

	local time = 0 --game:get_value(minigame.."_minigame_time") or 512000
	if type == nil then type = "chronometer" end
	timer_manager:start_timer(game, time_limit * 1000, type, true, true,
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

-- Called when time runs out
function minigame_manager:on_chronometer_timeout(map, minigame)
	timer_manager:stop_timer()
	local game = map:get_game()
	-- Set winning value to FALSE = losing.
	game:set_value(minigame.."_minigame_winning", false)
	minigame_manager:stop_minigame(map, minigame)
	sol.audio.play_sound("enemies/redead")

	if minigame == "marathon" then
		game:start_dialog("maps.caves.north_field.marathon_man.marathon_timeout")
	elseif minigame == "kakarico_maze" then
		game:start_dialog("maps.out.kakarico_village.maze.maze_loose")
		sol.audio.play_music("outside/kakarico")
	end
end

-- Stop playing, because of winning or chronometer timeout
function minigame_manager:stop_minigame(map, minigame)
	timer_manager:stop_timer()
	local game = map:get_game()
	
	if game:get_value(minigame.."_minigame_winning", true) then
		print("CONGRULATION OF WINNING GAME.."..minigame)
		--sol.audio.play_sound("common/prayer")
	else
		print("Minigame "..minigame.." has been lost.")
	end
	
	if game:get_value(minigame.."_minigame_playing") then
		-- Stop playing.
		game:set_value(minigame.."_minigame_playing", false)
	else
		-- We are not even playing!
		print("Error: minigame "..minigame.." is not started.")
	end
end

-- Win the minigame
function minigame_manager:win_minigame(map, minigame)
	local game = map:get_game()
	timer_manager:stop_timer()
	game:set_value(minigame.."_minigame_winning", true)

	-- Set the record time.
	if game:get_value(minigame.."_minigame_record_time") == nil
	or (game:get_value(minigame.."_minigame_time") < game:get_value(minigame.."_minigame_record_time")) then
		game:set_value(minigame.."_minigame_record_time", game:get_value(minigame.."_minigame_time"))
	end

	chrono_playing = false
--	minigame_manager:stop_minigame(map, minigame)
end

-- Get if has won
function minigame_manager:has_won(map, minigame, value)
	local game = map:get_game()
	return game:get_value(minigame.."_minigame_winning")
end

-- Get if currently playing
function minigame_manager:is_playing(map, minigame)
	local game = map:get_game()
	return game:get_value(minigame.."_minigame_playing")
end

return minigame_manager
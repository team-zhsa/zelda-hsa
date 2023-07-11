local minigame_manager = {}
local timer
local time

function minigame_manager:start_minigame(map, minigame)
	local game = map:get_game()
	local minigame_times_played = game:get_value(minigame.."_minigame_times_played") or 0
	if minigame == "marathon" then
		minigame_manager:start_marathon(map, minigame)
	end
	game:set_value(minigame.."_minigame_playing", true)
	game:set_value(minigame.."_minigame_winning", false)
	minigame_times_played = minigame_times_played + 1
	game:set_value(minigame.."_minigame_times_played", minigame_times_played)
end

function minigame_manager:start_chronometer(map, minigame)
	local game = map:get_game()
	timer = sol.timer.start(game, 1000, function()
		time = game:get_value(minigame.."_minigame_time") or 0
		time = time + 1
		print(time)
		game:set_value(minigame.."_minigame_time", time)
		print(game:get_value(minigame.."_minigame_time"))
		if game:get_value(minigame.."_minigame_playing") == true then
			return true  -- Repeat the timer.
		else
			minigame_manager:on_chronometer_timeout(map, minigame)
			return false
		end
	end)
	timer:set_suspended_with_map(true)
end

function minigame_manager:on_chronometer_timeout(map, minigame)
	local game = map:get_game()
	if minigame == "marathon" then

		-- Set winning value to FALSE = losing.
		game:set_value(minigame.."_minigame_winning", false)
		minigame_manager:end_minigame(map, minigame)
		sol.audio.play_sound("enemies/redead")
	end
end

function minigame_manager:end_minigame(map, minigame)
	local game = map:get_game()
	
	local winning_conditions = {
		marathon = game:get_value("marathon_minigame_time")
							< game:get_value("marathon_minigame_time_limit")
	}
	if game:get_value(minigame.."_minigame_winning", true) then
		print("CONGRULATION OF WINNING GAME.."..minigame)
	else
		print("Minigame "..minigame.." has been lost.")
	end


		-- Set the record time.
		if game:get_value(minigame.."_minigame_record_time") == nil 
		or game:get_value(minigame.."_minigame_time")
		< game:get_value(minigame.."_minigame_record_time") then
			game:set_value(minigame.."_minigame_record_time", time)
		end


	if game:get_value(minigame.."_minigame_playing") then
		-- Stop playing.
		game:set_value(minigame.."_minigame_playing", false)
	else
		-- We are not even playing!
		print("Error: minigame "..minigame.." is not started.")
	end
end

function minigame_manager:win_minigame(map, minigame)
	local game = map:get_game()
	game:set_value(minigame.."_minigame_winning", true)
	minigame_manager:end_minigame(map, minigame)
	sol.audio.play_sound("common/prayer")
end

function minigame_manager:is_playing(map, minigame)
	local game = map:get_game()
	return game:get_value(minigame.."_minigame_playing")
end

function minigame_manager:set_time_limit(map, minigame, time_limit)
	local game = map:get_game()
	game:set_value(minigame.."_minigame_time_limit", time_limit)
	sol.timer.start(game, time_limit * 1000, function()
		if not game:get_value(minigame.."_minigame_winning", true) then
			minigame_manager:on_chronometer_timeout(map, minigame)
		end
	end)
	timer:set_suspended_with_map(true)
end

function minigame_manager:get_time_limit(map, minigame)
	local game = map:get_game()
	return game:get_value(minigame.."_minigame_time_limit")
end

function minigame_manager:has_time_limit(map, minigame)
	local game = map:get_game()
	return game:get_value(minigame.."_minigame_time_limit") ~= nil
end

function minigame_manager:start_marathon(map, minigame)
	local game = map:get_game()
	minigame_manager:start_chronometer(map, "marathon")
	game:set_value(minigame.."_minigame_time", 0)
	minigame_manager:set_time_limit(map, minigame, 30)
end


return minigame_manager
local minigame_manager = {}
local timer

function minigame_manager:start_chronometer(map, minigame)
  local game = map:get_game()
  timer = sol.timer.start(game, 1000, function()
    local time = game:get_value(minigame.."_minigame_time") or 0
    time = time + 1
    print(time)
    game:set_value(minigame.."_minigame_time", time)
    print(game:get_value(minigame.."_minigame_time"))
    if game:get_value(minigame.."_minigame_playing") == true then
      return true  -- Repeat the timer.
    else
      if game:get_value(minigame.."_minigame_previous_time") == nil 
      or game:get_value(minigame.."_minigame_time")
      < game:get_value(minigame.."_minigame_previous_time") then
        game:set_value(minigame.."_minigame_previous_time", time)
      end
      return false
    end
  end)
  timer:set_suspended_with_map(true)
end

function minigame_manager:start_minigame(map, minigame)
  local game = map:get_game()
  if minigame == "marathon" then
    minigame_manager:start_marathon(map, minigame)
    game:set_value(minigame.."_minigame_playing", true)
  end
end

function minigame_manager:end_minigame(map, minigame)
  local game = map:get_game()
  if not game:get_value("marathon_minigame_playing") == true then
    print("Error: minigame "..minigame.." is not started.")
  else
    game:set_value(minigame.."_minigame_playing", false)
    timer:set_remaining_time(0)
  end
end

function minigame_manager:is_playing(map, minigame)
  local game = map:get_game()
  return game:get_value(minigame.."_minigame_playing")
end

function minigame_manager:start_marathon(map, minigame)
  local game = map:get_game()
  minigame_manager:start_chronometer(map, "marathon")
  game:set_value(minigame.."_minigame_time", 0)
end


return minigame_manager
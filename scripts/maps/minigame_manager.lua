local minigame_manager = {}

function minigame_manager:start_minigame(map, minigame)
  if minigame == marathon then
    minigame_manager:start_marathon(map)
  end
  game:set_value(minigame.."_minigame_playing", true)
end

function minigame_manager:start_chronometer(map, minigame)
  local game = map:get_game()
  local timer = sol.timer.start(game, 1000, function()
    local time = game:get_value(minigame.."_minigame_time") or 0
    time = time + 1000
    game:set_value(minigame.."_minigame_time", time)
    return true  -- Repeat the timer.
  end)
  timer:set_suspended_with_map(true)
end

function minigame_manager:start_marathon(map)
  
end


return minigame_manager
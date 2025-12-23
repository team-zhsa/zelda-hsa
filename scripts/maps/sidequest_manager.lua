-- Defines the dungeon information of a game.

-- Usage:
-- require("scripts/dungeons")

require("scripts/multi_events")
local parchment = require("scripts/menus/parchment")

local function initialise_sidequest_features(game)
  
  function parchment_start(quest_name)
    local map = game:get_map()
    game:set_suspended(true)
    sol.audio.play_sound("common/item_letter")
    local timer = sol.timer.start(map, 10, function()
      -- Show parchment with dungeon name.
      local line_1 = sol.language.get_string("pause.quest_log.new_quest")
      local line_2 = sol.language.get_string("pause.quest_log." .. quest_name)
      parchment:show(map, "quest", "center", 1500, line_1, line_2, nil, function()
        game:set_suspended(false)
      end)
    end)
    timer:set_suspended_with_map(false)
  end
  
  function parchment_end(quest_name)
    local map = game:get_map()
    game:set_suspended(true)
    local timer = sol.timer.start(map, 10, function()
      -- Show parchment with dungeon name.
      local line_1 = sol.language.get_string("pause.quest_log.quest_completed")
      local line_2 = sol.language.get_string("pause.quest_log." .. quest_name)
      parchment:show(map, "grey", "center", 1500, line_1, line_2, nil, function()
        game:set_suspended(false)
      end)
    end)
    timer:set_suspended_with_map(false)
  end

  function game:is_quest_active(quest_name)
		return game:get_value("sidequest_" .. quest_name .. "_active")
  end

  function game:set_quest_active(quest_name, active)
    if active == nil then
      active = true
    end

    game:set_value("sidequest_" .. quest_name .. "_active", active)
  end

  function game:start_quest(quest_name, parchment)
    game:set_quest_active(quest_name, true)
    if parchment then
      parchment_start(quest_name)
    end
  end

  function game:is_quest_finished(quest_name)
    return game:get_value("sidequest_" .. quest_name .. "_finished")
  end

  function game:set_quest_finished(quest_name, finished, parchment)
    if finished == nil then
      finished = true
    end

    if parchment == nil then
      parchment = false
    elseif parchement == true then
      parchment_end(quest_name)
    end
		game:set_quest_active(quest_name, false)
    game:set_value("sidequest_" .. dungeon_index .. "_finished", finished)
  end



end

-- Set up dungeon features on any game that starts.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", initialise_sidequest_features)

return true
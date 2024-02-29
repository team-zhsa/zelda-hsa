-- Defines the dungeon information of a game.

-- Usage:
-- require("scripts/dungeons")

require("scripts/multi_events")

local function initialise_sidequest_features(game)

  function game:is_quest_active(quest_name)
		return game:get_value("sidequest_" .. quest_name .. "_active")
  end

  -- Returns the current dungeon if any, or nil.
  function game:set_quest_active(quest_name, active)
    if active == nil then
      active = true
    end
    game:set_value("sidequest_" .. quest_name .. "_active", active)
  end

  function game:is_quest_finished(quest_name)
    return game:get_value("sidequest_" .. quest_name .. "_finished")
  end

  function game:set_quest_finished(quest_name, finished)
    if finished == nil then
      finished = true
    end
		game:set_quest_active(quest_name, false)
    game:set_value("sidequest_" .. dungeon_index .. "_finished", finished)
  end

end

-- Set up dungeon features on any game that starts.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", initialise_sidequest_features)

return true
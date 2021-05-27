-- This script initializes game values for a new savegame file.
-- You should modify the initialize_new_savegame() function below
-- to set values like the initial life and equipment
-- as well as the starting location.
--
-- Usage:
-- local initial_game = require("scripts/initial_game")
-- initial_game:initialize_new_savegame(game)

local initial_game = {}

-- Sets initial values to a new savegame file.
function initial_game:initialize_new_savegame(game)

  -- Initially give 3 hearts, the first tunic and the first wallet.
  game:set_max_life(12)
  game:set_life(game:get_max_life())
  game:get_item("green_tunic"):set_variant(1)
  game:get_item("rupee_bag"):set_variant(1)
  game:set_ability("sword", 0)
  game:set_value("hour_of_day", 0)
  game:set_value("time_of_day", "night")
  game:set_starting_location("menus/introduction")
	
end

return initial_game

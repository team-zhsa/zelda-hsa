-- This script initialises game values for a new savegame file.
-- You should modify the initialise_new_savegame() function below
-- to set values like the initial life and equipment
-- as well as the starting location.
--
-- Usage:
-- local initial_game = require("scripts/initial_game")
-- initial_game:initialise_new_savegame(game)

local initial_game = {}

-- Sets initial values to a new savegame file.
function initial_game:initialise_new_savegame(game)

  -- Initially give 3 hearts, the first tunic and the first wallet.
  game:set_max_life(12)
  game:set_life(game:get_max_life())
  game:get_item("tunic_green"):set_variant(1)
  game:get_item("rupee_bag"):set_variant(1)
  game:set_ability("sword", 0)
  game:set_value("hour_of_day", 10)
  game:set_value("time_of_day", "day")
  game:set_starting_location("menus/introduction", "destination")
  game:set_value("main_quest_step", 0)
  game:set_value("keyboard_map_menu", "w")

end


return initial_game

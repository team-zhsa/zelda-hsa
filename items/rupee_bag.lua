-- Lua script of item "rupee bag".
-- This script is executed only once for the whole game.

-- Variables
local item = ...

-- Event called when the game is initialised.
function item:on_created()

  item:set_savegame_variable("possession_rupee_bag")

end

function item:on_variant_changed(variant)

  item:get_game():set_max_money(999)

end


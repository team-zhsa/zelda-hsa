-- Lua script of item "magic powder bag".
-- This script is executed only once for the whole game.

-- Variables
local item = ...

-- Event called when the game is initialised.
function item:on_created()

  self:set_savegame_variable("possession_bombs_bag")
  
end

function item:on_started()

  self:on_variant_changed(self:get_variant())
  
end

function item:on_variant_changed(variant)

  -- The quiver determines the maximum amount of the bow.
  local bombs_counter = self:get_game():get_item("bombs_counter")
  if variant == 0 then
    bombs_counter:set_max_amount(0)
  else
    local max_amounts = {20, 30, 40}
    local max_amount = max_amounts[variant]
    -- Set the max value of the bow counter.
    bombs_counter:set_variant(1)
    bombs_counter:set_max_amount(max_amount)
  end
  
end

function item:on_obtaining(variant, savegame_variable)

  if variant > 0 then
    local bombs_counter = self:get_game():get_item("bombs_counter")
    bombs_counter:set_amount(bombs_counter:get_max_amount())
  end
  
end


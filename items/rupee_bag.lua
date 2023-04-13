-- Lua script of item "rupee bag".
-- This script is executed only once for the whole game.

-- Variables
local item = ...

-- Event called when the game is initialised.
function item:on_created()

  self:set_savegame_variable("possession_rupee_bag")
  self:set_brandish_when_picked(true)
  self:set_sound_when_brandished("common/big_item")
  
end

function item:on_started()

  self:on_variant_changed(self:get_variant())
  
end

function item:on_variant_changed(variant)

  -- The quiver determines the maximum amount of the bow.
  if variant == 0 then
    item:get_game():set_max_money(0)
  else
    local max_amounts = {199, 499, 999}
    local max_amount = max_amounts[variant]
    item:get_game():set_max_money(max_amount)
  end
  
end
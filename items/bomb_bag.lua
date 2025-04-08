-- Lua script of item "magic powder bag".
-- This script is executed only once for the whole game.

-- Variables
local item = ...

-- Event called when the game is initialised.
function item:on_created()
  self:set_sound_when_brandished("items/get_major_item")
  self:set_savegame_variable("possession_bombs_bag")
  
end

function item:on_started()

  self:on_variant_changed(self:get_variant())
  
end

function item:on_variant_changed(variant)

  -- The quiver determines the maximum amount of the bow.
  local bomb_counter = self:get_game():get_item("bomb_counter")
  if variant == 0 then
    bomb_counter:set_max_amount(0)
  else
    local max_amounts = {20, 30, 40}
    local max_amount = max_amounts[variant]
    -- Set the max value of the bow counter.
    bomb_counter:set_variant(1)
    bomb_counter:set_max_amount(max_amount)
  end
  
end

function item:on_obtaining(variant, savegame_variable)

  if variant > 0 then
    local bomb_counter = self:get_game():get_item("bomb_counter")
    bomb_counter:set_amount(bomb_counter:get_max_amount())
  end
  
end


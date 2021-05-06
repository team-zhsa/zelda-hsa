-- Lua script of enemy rolling bones spike.
-- This script is executed every time an enemy with this model is created.

-- Variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local sprite = enemy:create_sprite("enemies/boss/rolling_bones/spike")

-- Create spike
enemy:register_event("on_created", function(enemy)

  enemy:set_invincible(true)
  enemy:set_damage(2)
  enemy:set_drawn_in_y_order(false)
end)

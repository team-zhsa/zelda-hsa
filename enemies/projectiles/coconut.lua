-- Lua script of enemy coconut, mainly used by the Monkey enemy.

-- Global variables
local enemy = ...
local projectile_behavior = require("enemies/lib/projectile")

local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local circle = 2.0 * math.pi

-- Start the destroy animation and remove the enemy at the end.
function enemy:destroy()

  sprite:set_animation("destroyed", function()
    enemy:start_death()
  end)
end

-- Create an impact effect on hit.
enemy:register_event("on_hit", function(enemy)

  local x, y, _ = enemy:get_position()
  local offset_x, offset_y = sprite:get_xy()
  local hero_x, hero_y, _ = hero:get_position()
  enemy:start_brief_effect("entities/effects/impact_projectile", "default", (hero_x - x + offset_x) / 2, (hero_y - y + offset_y) / 2)
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  projectile_behavior.apply(enemy, sprite)
  enemy:set_life(1)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:start_shadow()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  sprite:set_animation("walking")
  enemy:set_damage(2)
  enemy:set_obstacle_behavior("flying")
  enemy:set_layer_independent_collisions(true)
end)

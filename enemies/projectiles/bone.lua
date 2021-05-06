-- Bone projectile, mainly used by the red Stalfos enemy.

local enemy = ...
local projectile_behavior = require("enemies/lib/projectile")

-- Global variables
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())

-- Remove the projectile on shield collision.
local function on_shield_collision()

  enemy:on_hit()
  enemy:start_death()
end

-- Start going to the hero.
function enemy:go()
  enemy:straight_go()
end

-- Create an impact effect on hit.
enemy:register_event("on_hit", function(enemy)
  enemy:start_brief_effect("entities/effects/impact_projectile", "default", sprite:get_xy())
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  projectile_behavior.apply(enemy, sprite)
  enemy:set_life(1)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 8)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  sprite:set_animation("walking")
  enemy:set_damage(2)
  enemy:set_obstacle_behavior("flying")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_hero_weapons_reactions({shield = on_shield_collision})
  enemy:go()
end)

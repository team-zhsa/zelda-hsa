----------------------------------
--
-- Genie's Fireball.
--
-- Projectile throwed by the genie.
--
-- Methods : enemy:extinguish()
--
----------------------------------

local enemy = ...
local projectile_behavior = require("enemies/lib/projectile")

-- Global variables
local sprite = enemy:create_sprite("enemies/boss/genie/fireball")

-- Start going to the hero.
function enemy:go()

  local movement = enemy:straight_go(nil, 80)
  movement:set_ignore_obstacles(true)
end

function enemy:extinguish()

  sprite:set_animation("extinguish", function()
    enemy:start_death()
  end)
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
  enemy:start_shadow()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  sprite:set_animation("walking")
  enemy:set_damage(4)
  enemy:set_invincible()
  enemy:set_layer_independent_collisions(true)
  enemy:set_obstacle_behavior("flying")
  enemy:set_pushed_back_when_hurt(false)
end)

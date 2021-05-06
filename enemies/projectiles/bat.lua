-- Bat projectile, mainly used by the Vire enemy.

local enemy = ...
local projectile_behavior = require("enemies/lib/projectile")

-- Global variables
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5

-- Configuration variables
local impulse_speed = 22
local impulse_distance = 30
local before_charging_delay = 500

-- Start a backward move then charge the hero.
function enemy:go(direction)

  local movement = enemy:start_straight_walking((direction or sprite:get_direction()) * quarter, impulse_speed, impulse_distance, function()
    sol.timer.start(enemy, before_charging_delay, function()
      local movement = enemy:straight_go()
      movement:set_ignore_obstacles(true)
    end)
  end)
  movement:set_ignore_obstacles(true)
end

-- Create an impact effect on hit.
enemy:register_event("on_hit", function(enemy)
  enemy:start_brief_effect("entities/effects/impact_projectile", "default", sprite:get_xy())
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  projectile_behavior.apply(enemy, sprite)
  enemy:set_life(1)
  enemy:set_size(24, 16)
  enemy:set_origin(12, 13)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  sprite:set_animation("walking")
  enemy:set_damage(2)
  enemy:set_obstacle_behavior("flying")
  enemy:set_layer_independent_collisions(true)
  enemy:set_pushed_back_when_hurt(false)
  enemy:go()
end)

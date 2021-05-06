-- Arrow projectile, throwed horizontally or vertically.

local enemy = ...
local projectile_behavior = require("enemies/lib/projectile")

-- Global variables
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5

-- Configuration variables
local planted_duration = 1000

-- Remove the projectile on shield collision.
local function on_shield_collision()
  enemy:on_hit()
end

-- Start another movement if direction changed.
function sprite:on_direction_changed()
  enemy:go()
end

-- Start going to the hero by an horizontal or vertical move.
function enemy:go()
  enemy:straight_go(sprite:get_direction() * quarter)
end

-- Create an impact effect on hit.
enemy:register_event("on_hit", function(enemy)

  -- Remove the entity when planted animation finished + some time.
  enemy:start_death(function()
    sprite:set_animation("reached_obstacle", function()
      sprite:set_paused()
      sprite:set_frame(1)
      sol.timer.start(enemy, planted_duration, function()
        finish_death()
      end)
    end)
  end)

  return false
end)

-- Directly remove the enemy on attacking hero
enemy:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)
  enemy:start_death()
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  projectile_behavior.apply(enemy, sprite)
  enemy:set_life(1)
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  sprite:set_animation("walking")
  enemy:set_damage(2)
  enemy:set_obstacle_behavior("flying")
  enemy:set_invincible()
  enemy:set_hero_weapons_reactions({shield = on_shield_collision})
  enemy:go()
end)

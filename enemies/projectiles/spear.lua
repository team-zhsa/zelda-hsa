-- Spear projectile, throwed horizontally or vertically, mostly used by spear Moblins enemies.

local enemy = ...
local projectile_behavior = require("enemies/lib/projectile")

-- Global variables
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5

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

  local direction = sprite:get_direction()
  
  -- Start an effect at the impact location.
  enemy:start_brief_effect("entities/effects/impact_projectile", "default", sprite:get_xy())

  -- Slightly move back.
  local movement = sol.movement.create("straight")
  movement:set_speed(64)
  movement:set_max_distance(10)
  movement:set_angle((direction + 2) % 4 * quarter)
  movement:set_ignore_obstacles()
  movement:start(enemy)

  -- Remove the entity when planted animation finished + some time.
  enemy:start_death(function()
    sprite:set_animation("hit", function()
      finish_death()
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

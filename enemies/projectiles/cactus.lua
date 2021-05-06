-- Cactus projectile, throwed away to the hero and bounce on obstacles, mostly used by pokey enemies.

local enemy = ...
local projectile_behavior = require("enemies/lib/projectile")

-- Global variables
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/pokey/body")
local quarter = math.pi * 0.5
local circle = math.pi * 2.0
local bounce_count = 0
local angle
local is_hero_pushed = false

-- Configuration variables
local speed = 200
local bounce_before_delete = 3

-- Start going away to the hero and bounce.
function enemy:go(new_angle)

  angle = new_angle or hero:get_angle(enemy)
  enemy:straight_go(angle, speed)
end

-- Make the enemy bounce on the shield.
local function bounce_on_shield()

  if is_hero_pushed then
    return
  end
  is_hero_pushed = true

  local normal_angle = hero:get_direction() * quarter
  if math.cos(math.abs(normal_angle - angle)) <= 0 then -- Don't bounce if the enemy is walking away the hero.
    enemy:go((2.0 * normal_angle - angle + math.pi) % circle)
  end
  enemy:go(hero, 150, 100, sprite, nil, function()
    is_hero_pushed = false
  end)
end

-- Create an impact effect on hit.
enemy:register_event("on_hit", function(enemy)

  bounce_count = bounce_count + 1
  enemy:go(enemy:get_obstacles_bounce_angle(angle))
  return bounce_count >= bounce_before_delete
end)

-- Directly remove the enemy on attacking hero
enemy:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)
  enemy:start_death()
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  projectile_behavior.apply(enemy, sprite)
  enemy:set_life(1)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({shield = bounce_on_shield}) -- Bounce on shield attack once propelled.

  sprite:set_animation("walking")
  enemy:set_damage(2)
  enemy:set_obstacle_behavior("flying")
  enemy:go()
end)

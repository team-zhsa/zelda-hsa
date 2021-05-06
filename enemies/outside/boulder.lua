----------------------------------
--
-- Boulder.
--
-- Randomly bounce to an angle to the south, from pi to 2pi.
-- Has to be manually removed when needed, ot continue its road forever.
--
-- Methods : enemy:start_bouncing()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local sprite = enemy:create_sprite("enemies/outside/boulder")
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local camera = map:get_camera()

-- Configuration variables
local bounce_duration = 600
local bounce_height = 12
local minimum_speed = 40
local maximum_speed = 80

-- Make the enemy bounce and go to a random target at the south the enemy.
function enemy:start_bouncing()

  local movement = enemy:start_jumping(bounce_duration, bounce_height, math.pi + math.random() * math.pi, math.random(minimum_speed, maximum_speed), function()
    enemy:start_bouncing()
  end)
  movement:set_ignore_obstacles(true)
end

-- Create an impact effect on hurt hero.
enemy:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)

  local x, y, _ = enemy:get_position()
  local offset_x, offset_y = sprite:get_xy()
  local hero_x, hero_y, _ = hero:get_position()
  enemy:start_brief_effect("entities/effects/impact_projectile", "default", (hero_x - x + offset_x) / 2, (hero_y - y + offset_y) / 2)
  hero:start_hurt(enemy, enemy_sprite, enemy:get_damage())
  
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_size(32, 32)
  enemy:set_origin(16, 29)
  enemy:start_shadow()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = "protected",
  	boomerang = "protected",
  	explosion = "ignored",
  	sword = "protected",
  	thrown_item = "protected",
  	fire = "protected",
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = "protected",
  	magic_powder = "ignored",
  	shield = "protected",
  	thrust = "protected"
  })

  sprite:set_xy(0, 0)
  sprite:set_animation("walking")
  enemy:set_damage(2)
  enemy:set_obstacle_behavior("flying")
  enemy:set_layer_independent_collisions(true)
  enemy:set_can_hurt_hero_running(true)
  enemy:start_bouncing()
end)

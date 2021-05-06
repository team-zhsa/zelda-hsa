-- Laser projectile, mainly used by the Beamos enemy.

-- Global variables
local enemy = ...
common_actions = require("enemies/lib/common_actions").learn(enemy)

local map = enemy:get_map()
local hero = map:get_hero()
local angle, max_distance
local is_in_progress = true
local has_hit = false

-- Configuration variables
local particle_interval = 10
local particle_speed = 500
local firing_duration = 200

-- Create an impact effect on a particle position.
function enemy:start_impact_effect(sprite)
  enemy:start_brief_effect("entities/effects/impact_projectile", "default", sprite:get_xy())
end

-- Create a new particle sprite to the enemy.
function enemy:create_particle()
 
  local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  sprite:set_animation("walking")

  local movement = sol.movement.create("straight")
  movement:set_angle(angle)
  movement:set_speed(particle_speed)
  movement:set_smooth(false)
  movement:start(sprite)

  function movement:on_position_changed()
    if sprite:get_movement() then -- Workaround: The event seems to be called again even if the movement is stopped and sprite already removed, ensure not to.
      local offset_x, offset_y = movement:get_xy()
      if enemy:test_obstacles(offset_x, offset_y) then
        movement:stop()
        enemy:remove_particle(sprite)
      end
    end
  end
end

-- Schedule the next laser particle.
function enemy:schedule_next_particle()

  sol.timer.start(enemy, particle_interval, function()
    if is_in_progress then
      enemy:create_particle()
      return particle_interval
    end
  end)
end

-- Remove a particle and stop creating new ones.
function enemy:remove_particle(sprite)

  if not has_hit then
    has_hit = true 
    enemy:start_impact_effect(sprite)
  end
  enemy:remove_sprite(sprite)

  -- Remove the enemy if no more particle.
  local has_sprite = false
  for _, _ in enemy:get_sprites() do
    has_sprite = true
    break
  end
  if not has_sprite then
    enemy:start_death()
  end
end

-- Create additional impact effect on hurt hero.
enemy:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)

  hero:start_hurt(2)
  enemy:start_impact_effect(enemy_sprite)
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)
  enemy:set_life(1)
  enemy:set_size(4, 4)
  enemy:set_origin(2, 2)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  angle = enemy:get_angle(hero)
  enemy:set_obstacle_behavior("flying")
  enemy:set_invincible()

  -- Schedule the first particle and start the firing timer.
  enemy:schedule_next_particle()
  sol.timer.start(enemy, firing_duration, function()
    is_in_progress = false
  end)
end)


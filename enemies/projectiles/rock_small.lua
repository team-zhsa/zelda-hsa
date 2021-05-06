local enemy = ...

-- Rock shot by another enemy (Octorok)

function enemy:on_created()
  self:set_life(1); self:set_damage(2)
  self:create_sprite("enemies/outside/octorok_stone")
  self:set_size(8, 8); self:set_origin(4, 4)
  self:set_invincible()
  self:set_minimum_shield_needed(2)
  self:set_obstacle_behavior("flying")
end

function enemy:on_obstacle_reached()
  enemy:remove()
end

function enemy:go(direction4)
  local angle = direction4 * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(enemy)

  enemy:get_sprite():set_direction(direction4)
end
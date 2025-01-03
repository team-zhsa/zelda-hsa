local enemy = ...

-- An animated fireball that circles around the enemy that created it.

function enemy:on_created()
  self:set_life(1); self:set_damage(2)
  self:create_sprite("enemies/dungeons/fireball_animated")
  self:set_size(16, 16); self:set_origin(8, 8)
  self:set_invincible()
  self:set_obstacle_behavior("flying")
end

function enemy:go_circle(center_entity, rayon, notRev)
  local m = sol.movement.create("circle")
  m:set_center(center_entity, 0, 0)
  m:set_radius(rayon)
  m:set_angular_speed(1)
  m:set_ignore_obstacles(true)
  m:set_clockwise(notRev)
  m:start(self)
end
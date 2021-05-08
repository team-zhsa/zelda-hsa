local enemy = ...
local particle_sprite = "enemies/dungeons/beamos_particle"
local damage = 2

-- Default parameters of the beam particle.

function enemy:on_created(properties)
  -- Get properties and target coordinates.
  if properties then
    if properties.particle_sprite then particle_sprite = properties.particle_sprite end
    if properties.damage then damage = properties.damage end
  end
  -- Set properties.
  self:set_size(8, 8)
  self:set_invincible()
  self:create_sprite(particle_sprite)
  self:set_damage(damage)
  self:set_minimum_shield_needed(3) -- Light shield.
  self:set_obstacle_behavior("flying")
  -- If particle isn't already destroyed after 5 seconds, do it manually.
  sol.timer.start(self, 500, function() self:remove() end)
end

function enemy:explode()
  self:remove()
end

function enemy:on_restarted()
  local dir4 = self:get_sprite():get_direction()
  local m = sol.movement.create("straight")
  if dir4 == 0 then angle = 0 end
  if dir4 == 1 then angle = math.pi / 2 end
  if dir4 == 2 then angle = math.pi end
  if dir4 == 3 then angle = 3 * math.pi / 2 end
  m:set_speed(32)
  m:set_angle(angle)
  m:start(self)
  m:set_ignore_obstacles(true)
end
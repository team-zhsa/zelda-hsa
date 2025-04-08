local enemy = ...

-- Pike that does not move.

function enemy:on_created()

  self:set_life(1)
  self:set_damage(4)
  self:create_sprite("enemies/dungeons/flame_red_fixed")
  self:set_size(32, 32)
  self:set_origin(12, 17)
  self:set_can_hurt_hero_running(true)
  self:set_invincible()
  self:set_traversable(false)
  enemy:set_attacking_collision_mode("touching")
end

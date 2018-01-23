local enemy = ...

-- The boss Zelda. 

function enemy:on_created()

  self:set_life(24)
  self:set_damage(2)
  self:set_hurt_style("boss")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
  self:create_sprite("npc/zelda")
  self:set_size(16, 16)
  self:set_origin(24, 29)
  self:set_invincible()
  self:set_attack_consequence("sword", 1)
  self:set_attack_consequence("thrown_item", 1)
  self:set_attack_consequence("arrow", 0)
end

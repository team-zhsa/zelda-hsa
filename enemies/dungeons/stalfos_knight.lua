local enemy = ...
local map = enemy:get_map()

-- Stalfos: An undead soldier boss.


function enemy:on_created()
  self:set_life(10); self:set_damage(2)
  self:create_sprite("enemies/stalfos_knight")
  self:set_size(32, 40); self:set_origin(16, 36)
  self:set_hurt_style("boss")
  self:set_attack_consequence("sword", 1)
  self:set_attack_consequence("explosion", "ignored")
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("arrow", 4)
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(false)
end

function enemy:on_restarted()

  movement = sol.movement.create("random")
  movement:set_speed(48)
  movement:start(enemy)
end
local enemy = ...
local rock = false

-- Deadrock: a basic enemy.

function enemy:on_created()
  self:set_life(6); self:set_damage(2)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16); self:set_origin(8, 13)
  self:go_random()
end

function enemy:go_random()
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("random_path")
  m:set_speed(52)
  m:start(self)
end

function enemy:on_hurt(attack)
  self.rock = true
  self:get_movement():stop()
  self:get_sprite():set_animation("immobilized")
  sol.timer.start(self, 10000, function()
    self:get_sprite():set_animation("shaking")
    sol.timer.start(self:get_map(), 1000, function()
      self.rock = false
      self:go_random()
    end)
  end)
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  self:get_sprite():set_direction(direction4)
end

function enemy:on_update()
  if self.rock then
     self:set_damage(0)
     self:set_can_attack(false)
     enemy:set_hero_weapons_reactions({
      arrow = "protected",
      boomerang = "protected",
      explosion = 6,
      sword = "protected",
      thrown_item = "protected",
      fire = "protected",
      jump_on = "ignored",
      hammer = "protected",
      hookshot = "protected",
      magic_powder = "ignored",
      shield = "protected",
      thrust = 6
    })
    if self:get_sprite():get_animation() ~= "immobilized" then self:get_sprite():set_animation("immobilized") end
  else
    self:set_damage(2)
    self:set_can_attack(true)
    enemy:set_hero_weapons_reactions({
      arrow = "protected",
      boomerang = "protected",
      explosion = 1,
      sword = 1,
      thrown_item = "protected",
      fire = "protected",
      jump_on = "ignored",
      hammer = "protected",
      hookshot = "protected",
      magic_powder = "ignored",
      shield = "protected",
      thrust = "protected"
    })
  end
end
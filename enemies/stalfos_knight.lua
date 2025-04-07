local enemy = ...
local map = enemy:get_map()
local vulnerable = false
local hidden = false
local hide_timer = nil
local hit_counter = 0

-- Possible positions where he lands.
local positions = {
  {x = 224, y = 288, direction4 = 3},
  {x = 232, y = 192, direction4 = 3},
  {x = 360, y = 304, direction4 = 3},
  {x = 336, y = 184, direction4 = 3}
}
if map:get_id() == "170" then
  -- Positions are different if this is the boss run.
  positions = {
    {x = 224, y = 238, direction4 = 3},
    {x = 232, y = 142, direction4 = 3},
    {x = 360, y = 254, direction4 = 3},
    {x = 336, y = 134, direction4 = 3}
  }
end

-- Stalfos: An undead soldier boss.

function enemy:on_created()
  self:set_life(10); self:set_damage(6)
  self:create_sprite("enemies/stalfos_knight")
  self:set_size(32, 40); self:set_origin(16, 36)
  self:set_hurt_style("boss")
  self:set_attack_arrow("protected")
  self:set_attack_hookshot("protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("explosion", "ignored")
  self:set_attack_consequence("sword", "custom")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(false)
end

function enemy:on_restarted()
  if not hidden and not vulnerable then
    if math.random(2) == 1 then
      hide_timer = sol.timer.start(self, math.random(10)*500, function() self:hide() end)
    else
      sol.timer.start(self, 500, function()
        self:create_enemy({ breed = "stalfos_head", treasure_name = "magic_flask" })
      end)
      self:go_hero()
    end
  elseif hidden then
    self:unhide()
  end
end

function enemy:on_obstacle_reached(movement)
  enemy:restart()
end

function enemy:on_hurt()
  vulnerable = false; hidden = false
  self:get_sprite():set_animation("hurt")
  hit_counter = 0
end

function enemy:on_update()
  if vulnerable then
    self:set_attack_consequence("explosion", 1)
    self:set_attack_consequence("sword", "ignored")
  else
    self:set_attack_consequence("explosion", "ignored")
    self:set_attack_consequence("sword", "custom")
  end
end

function enemy:hide()
  sol.timer.start(self:get_map(), 5000, function() self:unhide() end)
  vulnerable = false; hidden = true
  self:get_sprite():set_animation("head")
  sol.audio.play_sound("stalfos_laugh")
  self:create_enemy({ breed = "stalfos_head", treasure_name = "bomb" })
  sol.timer.start(self, 1000, function()
    local m = sol.movement.create("jump")
    m:set_direction8(2)
    m:set_distance(256)
    m:set_speed(80)
    m:start(self)
    sol.audio.play_sound("jump")
    sol.timer.start(self, 2000, function() self:set_position(-100, -100) end)
  end)
end

function enemy:unhide()
  vulnerable = false; hidden = false
  local position = (positions[math.random(#positions)])
  sol.audio.play_sound("stalfos_laugh")
  self:set_position(position.x, position.y)
  self:get_sprite():set_direction(position.direction4)
  sol.timer.start(self, 2000, function() self:go_hero() end)
end

function enemy:go_hero()
  vulnerable = false; hidden = false
  local m = sol.movement.create("target")
  m:set_speed(32)
  m:start(self)
  sol.timer.start(enemy, math.random(10)*1000, function() enemy:restart() end)
end

function enemy:on_custom_attack_received(attack, sprite)
  if hide_timer ~= nil then hide_timer:stop() end
  if attack == "sword" then
    self:get_sprite():set_animation("hit")
    hit_counter = hit_counter + 1
    sol.audio.play_sound("enemy_hurt")
    if hit_counter == 3 then
      self:set_attack_consequence("sword", "ignored")
      vulnerable = true
      self:stop_movement()
      sol.audio.play_sound("enemy_awake")
      self:get_sprite():set_animation("immobilized")
      self:set_attack_consequence("explosion", 1)
      attack_timer = sol.timer.start(self, 15000, function()
        vulnerable = false
        sol.audio.play_sound("hero_pushes")
        self:set_attack_consequence("explosion", "ignored")
        self:set_attack_consequence("sword", "custom")
        sol.timer.start(self, 1000, function() self:get_sprite():set_animation("shaking") end)
        hit_counter = 0
      end)
    end
  end
  
  function sprite:on_animation_finished(animation)
    if animation == "shaking" then
      vulnerable = false
      self:get_sprite():set_animation("walking")
      self:restart()
    end
  end
end
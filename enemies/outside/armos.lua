local enemy = ...
local going_hero = false
local near_hero = false
local timer

-- Armos Status: Stationary until hero gets close, then comes to life.

function enemy:on_created()
  self:set_life(2); self:set_damage(2)
  local sprite = self:create_sprite("enemies/outside/armos")
  self:set_size(24, 40); self:set_origin(12, 35)
  self:set_hurt_style("monster")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(true)
  self:set_invincible()
end

function enemy:on_obstacle_reached(movement)
  if not going_hero then
    self:stop(movement)
    self:check_hero()
  end
end

function enemy:on_restarted()
  self:check_hero()
end

function enemy:on_hurt()
  if timer ~= nil then
    timer:stop()
    timer = nil
  end
  going_hero = false
end

function enemy:check_hero()
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  near_hero = layer == hero_layer and self:get_distance(hero) < 100

  if near_hero and not going_hero then
    self:go_hero()
  elseif not near_hero and going_hero then
    self:stop(self:get_movement())
    self:get_sprite():set_animation("immobilized")
  elseif not going_hero or not near_hero then
    self:get_sprite():set_animation("immobilized")
  end
  timer = sol.timer.start(self, 2000, function() self:check_hero() end)
end

function enemy:stop(movement)
  self:set_attack_arrow("protected")
  self:set_can_attack(false)
  self:set_can_hurt_hero_running(false)
  self:get_sprite():set_animation("immobilized")
  self:stop_movement()
  going_hero = false
end

function enemy:go_hero()
  self:set_attack_arrow(1)
  self:set_can_attack(true)
  self:set_can_hurt_hero_running(true)
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  m:set_speed(32 + math.random(10))
  m:start(self)
  going_hero = true
end
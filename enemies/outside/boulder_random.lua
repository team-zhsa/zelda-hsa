local enemy = ...

-- Boulder: Large rock that rolls and can hit the hero.

function enemy:on_created()
  self:set_life(1); self:set_damage(1)
  self:create_sprite("enemies/outside/boulder")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:set_can_hurt_hero_running(true)
  self:set_invincible()
end

function enemy:on_restarted()
  local sprite = self:get_sprite()
  local direction4 = sprite:get_direction()
  local m = sol.movement.create("random")
  m:set_speed(41)
  m:start(self)
end

function enemy:on_obstacle_reached(movement)
  sol.audio.play_sound("stone")
  self:restart()
end
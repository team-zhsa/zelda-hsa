local enemy = ...

-- Rat.

local squeaking = false

function enemy:on_created()
  self:set_life(1)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16); self:set_origin(8, 13)
end

function enemy:squeak()
  squeaking = true
  sol.timer.start(enemy, math.random(10)*1000, function()
    enemy:get_sprite():set_animation("walking")
		sol.audio.play_sound("enemies/rat")
    squeaking = false
    sol.timer.start(enemy, math.random(10)*1000, function() enemy:restart() end)
  end)
end

  function enemy:on_movement_changed(movement)
    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
  end

function enemy:on_restarted()
  squeaking = false
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
  if math.random(10) < 5 then
    enemy:squeak()
  end
  enemy:set_hero_weapons_reactions({
  	arrow = 1,
  	boomerang = 1,
  	explosion = 1,
  	sword = 1,
  	thrown_item = 1,
  	fire = 1,
  	jump_on = "ignored",
  	hammer = 1,
  	hookshot = 1,
  	magic_powder = 1,
  	shield = "protected",
  	thrust = 1
  })

  -- States.
  enemy:set_can_attack(true)
  enemy:set_damage(2)
end

function enemy:on_immobilized()
  squeaking = false
end
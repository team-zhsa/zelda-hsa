local enemy = ...

-- Bari: a flying enemy that follows the hero and tries to electrocute him.

local shocking = false

function enemy:on_created()
  self:set_life(3); self:set_damage(6)
  self:create_sprite("enemies/dungeons/bari_blue")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:set_attack_consequence("hookshot", "immobilized")
end

function enemy:shock()
  shocking = true
  enemy:get_sprite():set_animation("shaking")
  sol.timer.start(enemy, math.random(10)*1000, function()
    enemy:get_sprite():set_animation("walking")
    shocking = false
    sol.timer.start(enemy, math.random(10)*1000, function() enemy:restart() end)
  end)
end

function enemy:on_restarted()
  shocking = false
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
  if math.random(10) < 5 then
    enemy:shock()
  end
end

function enemy:on_immobilized()
  shocking = false
end

function enemy:on_hurt_by_sword(hero, enemy_sprite)
  if shocking == true then
    hero:start_electrocution(1500)
  else
    self:hurt(1)
    enemy:remove_life(1)
  end
end
function enemy:on_attacking_hero(hero, enemy_sprite)
  if shocking == true then
    hero:start_electrocution(1500)
  else
    hero:start_hurt(2)
  end
end

local function electrocute()

  local camera = map:get_camera()
  local surface = camera:get_surface()
  hero:get_sprite():set_ignore_suspend(true)
  game:set_suspended(true)
  sprite:set_animation("shocking")
  audio_manager:play_sound("ennemies/bari/b_state_e")
  hero:set_animation("electrocuted")
  effect_model.start_effect(surface, game, 'in', false)
  local shake_config = {
    count = 32,
    amplitude = 4,
    speed = 180,
  }
  camera:shake(shake_config, function()
    game:set_suspended(false)
    sprite:set_animation("walking")
    hero:unfreeze()
    hero:start_hurt(enemy:get_damage())
  end)
end
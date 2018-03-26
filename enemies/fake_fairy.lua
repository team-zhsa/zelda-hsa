-- Lua script of enemy fake_fairy.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()

  movement = sol.movement.create("target")
  movement:set_target(hero)
  movement:set_speed(48)
  movement:start(enemy)
end

function enemy:fire_step_1()

  sprite:set_animation("arms_up")
  sol.timer.start(self, 1000, function() self:fire_step_2() end)
end

function enemy:fire_step_2()

  if math.random(100) <= blue_fireball_proba then
    sprite:set_animation("preparing_blue_fireball")
  else
    sprite:set_animation("preparing_red_fireball")
  end
  sol.audio.play_sound("boss_charge")
  sol.timer.start(self, 1500, function() self:fire_step_3() end)
end

function enemy:fire_step_3()

  local sound, breed
  if sprite:get_animation() == "preparing_blue_fireball" then
    sound = "cane"
    breed = "blue_fireball_triple"
  else
    sound = "boss_fireball"
    breed = "red_fireball_triple"
  end
  sprite:set_animation("stopped")
  sol.audio.play_sound(sound)

  vulnerable = true
  sol.timer.start(self, 1300, function() self:restart() end)

  local function throw_fire()

    nb_sons_created = nb_sons_created + 1
    self:create_enemy{
      name = "agahnim_fireball_" .. nb_sons_created,
      breed = breed,
      x = 0,
      y = -21
    }
  end

  throw_fire()
  if self:get_life() <= initial_life / 2 then
    sol.timer.start(self, 200, function() throw_fire() end)
    sol.timer.start(self, 400, function() throw_fire() end)
  end
end

function enemy:receive_bounced_fireball(fireball)

  if fireball:get_name():find("^agahnim_fireball")
      and vulnerable then
    -- Receive a fireball shot back by the hero: get hurt.
    sol.timer.stop_all(self)
    fireball:remove()
    self:hurt(1)
  end
end

function enemy:on_hurt(attack)

  local life = self:get_life()
  if life <= 0 then
    self:get_map():remove_entities("agahnim_fireball")
    self:set_life(1)
    finished = true
  elseif life <= initial_life / 3 then
    blue_fireball_proba = 50
  end
end
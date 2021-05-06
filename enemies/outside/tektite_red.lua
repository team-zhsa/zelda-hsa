----------------------------------
--
-- Tektite.
--
-- Wait a random time then pounce to the hero, and restarts.
--
-- Methods : enemy:start_pouncing()
--           enemy:wait()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5

-- Configuration variables
local waiting_minimum_duration = 500
local waiting_maximum_duration = 2000
local shaking_duration = 1000
local jumping_duration = 700
local jumping_height = 16
local jumping_speed = 128

-- Pounce to the hero.
function enemy:start_pouncing()

  sprite:set_animation("jumping")
  enemy:start_jumping(jumping_duration, jumping_height, enemy:get_angle(hero), jumping_speed, function()
    enemy:restart()
  end)
end

-- Wait a few time then shake and pounce.
function enemy:wait()

  sol.timer.start(enemy, math.random(waiting_minimum_duration, waiting_maximum_duration), function()
    sprite:set_animation("shaking")
    sol.timer.start(enemy, shaking_duration, function()
      enemy:start_pouncing()
    end)
  end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(2)
  enemy:set_size(24, 16)
  enemy:set_origin(12, 13)
  enemy:start_shadow()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = 2,
  	boomerang = 2,
  	explosion = 2,
  	sword = 1,
  	thrown_item = 2,
  	fire = 2,
  	jump_on = "ignored",
  	hammer = 2,
  	hookshot = 2,
  	magic_powder = 2,
  	shield = "protected",
  	thrust = 2
  })

  -- States.
  sprite:set_xy(0, 0)
  enemy:set_obstacle_behavior("normal")
  enemy:set_can_attack(true)
  enemy:set_damage(2)
  enemy:wait()
end)
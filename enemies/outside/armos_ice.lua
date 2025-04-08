----------------------------------
--
-- Armos.
--
-- Wait a random time then pounce to the hero, and restarts.
--
-- Methods : enemy:awaken()
--           enemy:check_hero()
--           enemy:stop()
--           enemy:go_hero()
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
local going_hero = false
local near_hero = false
local timer

-- Configuration variables
local waiting_minimum_duration = 400
local waiting_maximum_duration = 500
local shaking_duration = 500
local jumping_duration = 400
local jumping_height = 8
local jumping_speed = 32 + math.random(10)
local triggering_distance = 96

-- Wait a few time then shake and pounce.
function enemy:awaken()
  sol.timer.start(enemy, math.random(waiting_minimum_duration, waiting_maximum_duration), function()
    sprite:set_animation("shaking")
    sol.audio.play_sound("enemies/armos_awake")
    sol.timer.start(enemy, shaking_duration, function()
      enemy:go_hero()
    end)
  end)
end

function enemy:check_hero()
  local hero = enemy:get_map():get_entity("hero")
  local _, _, layer = enemy:get_position()
  local _, _, hero_layer = hero:get_position()
  near_hero = layer == hero_layer and enemy:get_distance(hero) < triggering_distance

  if near_hero and not going_hero then
    enemy:awaken()
  elseif not near_hero and going_hero then
    enemy:stop(enemy:get_movement())
    enemy:get_sprite():set_animation("immobilized")
  elseif not going_hero or not near_hero then
    enemy:get_sprite():set_animation("immobilized")
  end
  timer = sol.timer.start(enemy, 2000, function()
    enemy:check_hero()
  end)
end

function enemy:stop(movement)
  enemy:set_can_attack(false)
  enemy:get_sprite():set_animation("immobilized")
  enemy:stop_movement()
  going_hero = false

  enemy:set_hero_weapons_reactions({
    arrow = "protected",
    boomerang = "protected",
    explosion = "protected",
    sword = "protected",
    thrown_item = "protected",
    fire = "protected",
    jump_on = "ignored",
    hammer = "protected",
    hookshot = "protected",
    magic_powder = "protected",
    shield = "protected",
    thrust = "protected"
  })
end

function enemy:go_hero()
  enemy:set_can_attack(true)
  enemy:set_traversable(true)
  sprite:set_animation("jumping")
  enemy:start_jumping(jumping_duration, jumping_height, enemy:get_angle(hero), jumping_speed, function()
    sol.audio.play_sound("enemies/armos_jump")
    if enemy:get_distance(hero) < triggering_distance then
      enemy:go_hero()
    else
      enemy:restart()
    end
  end)
  going_hero = true

  enemy:set_hero_weapons_reactions({
    arrow = 3,
    boomerang = "immobilized",
    explosion = 6,
    sword = 1,
    thrown_item = 3,
    fire = 6,
    jump_on = "ignored",
    hammer = 6,
    hookshot = "immobilized",
    magic_powder = "protected",
    shield = "protected",
    thrust = 6
  })
end

-- Initialisation.
enemy:register_event("on_created", function()
  enemy:set_life(6)
  enemy:set_size(16, 16); enemy:set_origin(8, 27)
  enemy:set_pushed_back_when_hurt(true)
  enemy:set_push_hero_on_sword(false)
  enemy:set_invincible()
end)

-- Restart settings.
enemy:register_event("on_restarted", function()

  enemy:set_hero_weapons_reactions({
    arrow = "protected",
    boomerang = "protected",
    explosion = "protected",
    sword = "protected",
    thrown_item = "protected",
    fire = "protected",
    jump_on = "ignored",
    hammer = "protected",
    hookshot = "protected",
    magic_powder = "protected",
    shield = "protected",
    thrust = "protected"
  })
  -- States.
  sprite:set_xy(0, 0)
  enemy:set_obstacle_behavior("normal")
  enemy:set_traversable(false)
  enemy:set_can_attack(false)
  enemy:set_damage(4)
  enemy:check_hero()
end)

enemy:register_event("on_hurt", function()
  if timer ~= nil then
    timer:stop()
    timer = nil
  end
  going_hero = false
end)

----------------------------------
--
-- Zol Green.
--
-- Start invisible and appear when the hero is close enough, then pounce several times to him.
--
-- Methods : enemy:start_pouncing()
--           enemy:appear()
--           enemy:disappear()
--           enemy:wait()
--
----------------------------------

-- Variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local shadow

-- Configuration variables.
local walking_speed = 4
local jumping_speed = 64
local jumping_height = 12
local jumping_duration = 600
local shaking_duration = 1000
local between_jump_duration = 500
local maximum_jump_in_a_row = 8
local triggering_distance = 60

-- Make the enemy vulnerable and hurtful.
local function set_vulnerable()

  enemy:set_can_attack(true)
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
end

-- Start a single jump of the serie.
local function start_jumping(current_jump_number, jump_in_a_row)

  local hero_x, hero_y, _ = hero:get_position()
  local enemy_x, enemy_y, _ = enemy:get_position()
  local angle = math.atan2(hero_y - enemy_y, enemy_x - hero_x) + math.pi
  enemy:start_jumping(jumping_duration, jumping_height, angle, jumping_speed, function()

    -- Contine jumping or disappear on jump finished.
    sprite:set_animation("shaking")
    if enemy:get_distance(hero) > triggering_distance or current_jump_number >= jump_in_a_row then
      enemy:disappear()
    else
      sol.timer.start(enemy, between_jump_duration, function()
        start_jumping(current_jump_number + 1, jump_in_a_row)
      end)
    end
  end)
  sprite:set_animation("jumping")
end

-- Start pouncing to the hero.
function enemy:start_pouncing(jump_in_a_row)

  set_vulnerable()
  start_jumping(1, math.random(maximum_jump_in_a_row))
end

-- Make the enemy appear.
function enemy:appear()

  enemy:set_visible()
  sprite:set_animation("appearing", function() 
    set_vulnerable()
    sprite:set_animation("shaking")
    sol.timer.start(enemy, 1000, function()
      enemy:start_pouncing()
    end)
  end)
end

-- Make the enemy disappear.
function enemy:disappear()

  sprite:set_animation("disappearing", function()
    enemy:restart()
  end)
end

-- Wait for the hero to be close enough and appear if yes.
function enemy:wait()

  sol.timer.start(enemy, 100, function()
    if enemy:get_distance(hero) < triggering_distance then
      enemy:appear()
      return false
    end
    return true
  end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  shadow = enemy:start_shadow()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_invincible()

  -- States.
  sprite:set_xy(0, 0)
  enemy:set_obstacle_behavior("normal")
  enemy:set_damage(2)
  enemy:set_can_attack(false)
  enemy:set_visible(false)
  enemy:wait()
end)

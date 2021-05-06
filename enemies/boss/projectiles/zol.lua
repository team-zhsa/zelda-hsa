----------------------------------
--
-- Zol.
--
-- A simple Zol used by the Slime Eye and in fake chests.
-- Behave pretty much like the Zol Red except it doesn't split into Gels and the jump doesn't depend on the distance to the hero.
--
-- Methods : enemy:start_walking()
--           enemy:start_pouncing()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local sprite = enemy:create_sprite("enemies/zol_green")
local map = enemy:get_map()
local hero = map:get_hero()
local is_attacking

-- Configuration variables
local walking_speed = 4
local jumping_speed = 64
local jumping_height = 12
local jumping_duration = 600
local walking_minimum_speed = 2000
local walking_maximum_speed = 2000
local shaking_duration = 1000

-- Start moving to the hero, and jump when he is close enough.
function enemy:start_walking()
  
  local movement = enemy:start_target_walking(hero, walking_speed)

  sol.timer.start(enemy, math.random(walking_minimum_speed, walking_maximum_speed), function()
    if not is_attacking then
      is_attacking = true
      movement:stop()
      
      -- Shake for a short duration then start attacking.
      sprite:set_animation("shaking")
      sol.timer.start(enemy, shaking_duration, function()
         enemy:start_pouncing()
      end)
    end
  end)
end

-- Start pouncing to the hero.
function enemy:start_pouncing()

  local hero_x, hero_y, _ = hero:get_position()
  local enemy_x, enemy_y, _ = enemy:get_position()
  local angle = math.atan2(hero_y - enemy_y, enemy_x - hero_x) + math.pi
  enemy:start_jumping(jumping_duration, jumping_height, angle, jumping_speed, function()
    enemy:restart()
  end)
  sprite:set_animation("jumping")
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
  is_attacking = false
  sprite:set_xy(0, 0)
  enemy:set_damage(1)
  enemy:set_can_attack(true)
  enemy:set_obstacle_behavior("normal")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_damage(2)
  enemy:start_walking()
end)
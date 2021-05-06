----------------------------------
--
-- Ballchain Soldier.
--
-- Soldier enemy holding a spiked cannonball at the end of a chain.
-- Slowly moves to the hero, and throw the cannonball to the hero once close enough.
-- 
--
-- Methods : enemy:start_walking()
--           enemy:start_attacking()
--
----------------------------------
-- TODO Don't move on restart by hurt and currently attacking or aiming.

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5
local flail
local is_attacking = false

-- Configuration variables
local right_hand_offset_x = -8
local right_hand_offset_y = -19
local throwed_chain_origin_offset_x = 1
local throwed_chain_origin_offset_y = 17
local walking_speed = 16
local attack_triggering_distance = 80
local aiming_minimum_duration = 1500
local throwed_ball_speed = 200

-- Start the enemy movement.
function enemy:start_walking()

  local movement = enemy:start_target_walking(hero, walking_speed)

  function movement:on_position_changed()
    if enemy:is_near(hero, attack_triggering_distance) then
      enemy:start_attacking()
    end
  end

  sprite:set_animation("walking")
end

-- Make the enemy aim then throw its ball.
function enemy:start_attacking()

  -- The flail doesn't restart on hurt and finish its possble running move, make sure only one attack is triggered at the same time.
  if is_attacking then
    return
  end
  is_attacking = true

  enemy:stop_movement()
  sprite:set_animation("aiming")
  flail:start_aiming(hero, aiming_minimum_duration, function()

    sprite:set_animation("throwing")
    flail:set_chain_origin_offset(throwed_chain_origin_offset_x, throwed_chain_origin_offset_y)
    flail:start_throwing_out(hero, throwed_ball_speed, function()

      sprite:set_animation("aiming")
      flail:set_chain_origin_offset(0, 0)
      flail:start_pulling_in(throwed_ball_speed, function()
        is_attacking = false
        enemy:restart()
      end)
    end)
  end)
end

-- Kill the flail on dead.
enemy:register_event("on_dead", function(enemy)
  flail:start_death()
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(8)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)

  -- Create the flail.
  flail = enemy:create_enemy({
    name = (enemy:get_name() or enemy:get_breed()) .. "_flail",
    breed = "boss/projectiles/flail",
    direction = 2,
    x = right_hand_offset_x,
    y = right_hand_offset_y,
    layer = enemy:get_layer() + 1
  })
  enemy:start_welding(flail, right_hand_offset_x, right_hand_offset_y)

  -- Make flail disappear when the enemy became invisible on dying.
  enemy:register_event("on_dying", function(enemy)
    flail:start_death(function()
      sol.timer.start(flail, 300, function() -- No event when the enemy became invisible, hardcode a timer.
        finish_death()
      end)
    end)
  end)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = 4,
  	boomerang = 4,
  	explosion = 4,
  	sword = 1,
  	thrown_item = 4,
  	fire = 4,
  	jump_on = "ignored",
  	hammer = 4,
  	hookshot = 4,
  	magic_powder = 4,
  	shield = "protected",
  	thrust = 4
  })

  -- States.
  flail:set_chain_origin_offset(0, 0)
  enemy:set_can_attack(true)
  enemy:set_damage(2)
  enemy:start_walking()
end)

----------------------------------
--
-- Stalfos Blue.
--
-- Moves to the hero and pounce above him when close enough, then wait a few time in the air and finally stomp down the hero.
--
-- Methods : enemy:start_walking()
--           enemy:start_attacking()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())

-- Configuration variables
local attack_triggering_distance = 32
local walking_speed = 32
local jumping_speed = 128
local jumping_height = 32
local on_air_duration = 700
local jumping_duration = 120
local stompdown_duration = 50
local stunned_duration = 400

-- Set the behavior for each items.
local function set_vulnerable()

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
end

-- Start moving to the hero, and attack when he is close enough.
function enemy:start_walking()

  local movement = enemy:start_target_walking(hero, walking_speed)
  function movement:on_position_changed()
    if enemy:is_near(hero, attack_triggering_distance) then
      movement:stop()
      enemy:start_attacking()
    end
  end
end

-- Event triggered when the enemy is close enough to the hero.
function enemy:start_attacking()

  -- Start jumping on the current hero position.
  local target_x, target_y, _ = hero:get_position()
  local movement = sol.movement.create("target")
  movement:set_speed(jumping_speed)
  movement:set_target(target_x, target_y)
  movement:set_smooth(false)
  movement:start(enemy)

  sprite:set_animation("jumping")
  enemy:set_invincible()
  enemy:set_can_attack(false)
  enemy:start_flying(jumping_duration, jumping_height, function()
    sprite:set_animation("attack_landing")

    -- Wait for a delay and start the stomp down.
    sol.timer.start(enemy, on_air_duration, function()
      enemy:stop_flying(stompdown_duration, function()
        set_vulnerable()
        enemy:set_can_attack(true)

        -- Start a visual effect at the landing impact location, wait a few time and restart.
        enemy:start_brief_effect("entities/effects/impact_projectile", "default", -12, 0)
        enemy:start_brief_effect("entities/effects/impact_projectile", "default", 12, 0)
        sol.timer.start(enemy, stunned_duration, function()
          enemy:restart()
        end)
      end)
    end)
  end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(3)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:start_shadow()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  set_vulnerable()

  -- States.
  sprite:set_xy(0, 0)
  enemy:set_obstacle_behavior("normal")
  enemy:set_can_attack(true)
  enemy:set_damage(1)
  enemy:start_walking()
end)

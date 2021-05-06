----------------------------------
--
-- Spiked Beetle.
--
-- Moves randomly over horizontal and vertical axis, and charges the hero when aligned with him.
-- Bounce and flip the enemy on collision with the shield while charging, and make it vulnerable.
--
-- Methods : enemy:start_walking()
--           enemy:start_charging()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)
local audio_manager = require("scripts/audio_manager")

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5
local eighth = math.pi * 0.25
local is_upside_down = false

-- Configuration variables
local walking_angles = {0, quarter, 2.0 * quarter, 3.0 * quarter}
local walking_speed = 24
local walking_minimum_distance = 16
local walking_maximum_distance = 96
local charging_speed = 100
local charging_max_distance = 100
local alignement_thickness = 16

local jumping_speed = 40
local jumping_height = 15
local jumping_duration = 500

local walking_pause_duration = 500
local is_exhausted_duration = 500
local upside_down_duration = 4500
local shaking_duration = 500
local before_charging_delay = 100

-- Start the enemy movement.
function enemy:start_walking()

  local movement = enemy:start_straight_walking(walking_angles[math.random(4)], walking_speed, math.random(walking_minimum_distance, walking_maximum_distance), function()
    sol.timer.start(enemy, walking_pause_duration, function()
      if not is_charging and not is_upside_down then
        enemy:start_walking()
      end
    end)
  end)
end

-- Start charging.
function enemy:start_charging()

  is_charging = true

  sol.timer.start(enemy, before_charging_delay, function()
    if is_charging and not is_upside_down then

      -- Charging movement.
      enemy:stop_movement()
      local movement = sol.movement.create("straight")
      movement:set_speed(charging_speed)
      movement:set_max_distance(charging_max_distance)
      movement:set_angle(enemy:get_direction4_to(hero) * quarter)
      movement:set_smooth(false)
      movement:start(enemy)
      sprite:set_direction(movement:get_direction4())

      -- Stop charging on movement finished or obstacle reached.
      local function stop_charging()
        sol.timer.start(enemy, is_exhausted_duration, function()
          if is_charging and not is_upside_down then
            enemy:restart()
          end
        end)
      end
      function movement:on_finished()
        stop_charging()
      end
      function movement:on_obstacle_reached()
        stop_charging()
      end
    end
  end)
end

-- Flip the enemy on collision with the shield and make it vulnerable.
local function on_shield_collision()

  if not is_upside_down then
    is_upside_down = true
    is_charging = false
    enemy:stop_movement()
    enemy:start_brief_effect("entities/effects/impact_projectile", "default")

    enemy:set_hero_weapons_reactions({
    	arrow = 2,
    	boomerang = 2,
    	explosion = 2,
    	sword = 1,
    	thrown_item = 2,
    	fire = 2,
    	jump_on = 2,
    	hammer = 2,
    	hookshot = 2,
    	magic_powder = 2,
    	shield = "protected",
    	thrust = 2
    })

    -- Make the enemy jump while flipping.
    local angle = sprite:get_direction() * quarter + math.pi
    enemy:start_jumping(jumping_duration, jumping_height, angle, jumping_speed, function()

      -- Wait for a delay and restart the enemy when flipped.
      audio_manager:play_entity_sound(enemy, "bounce")
      sol.timer.start(enemy, upside_down_duration, function()
        if is_upside_down then
          sprite:set_animation("shaking")
          sol.timer.start(enemy, shaking_duration, function()
            if is_upside_down then
              enemy:restart()
            end
          end)
        end
      end)
    end)
    sprite:set_animation("renverse")
    audio_manager:play_entity_sound(enemy, "bounce")
  end
end

-- Passive behaviors needing constant checking.
enemy:register_event("on_update", function(enemy)

  if enemy:is_immobilized() then
    return
  end

  -- Start charging if the hero is aligned with the enemy.
  if not is_charging and not is_upside_down and enemy:is_aligned(hero, alignement_thickness) then
    enemy:start_charging()
  end
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(2)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:start_shadow()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = "protected",
  	boomerang = "protected",
  	explosion = "ignored",
  	sword = "protected",
  	thrown_item = "protected",
  	fire = "protected",
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = "protected",
  	magic_powder = "ignored",
  	shield = on_shield_collision,
  	thrust = "protected"
  })

  -- States.
  sprite:set_xy(0, 0)
  enemy:set_obstacle_behavior("normal")
  enemy:set_can_attack(true)
  enemy:set_damage(2)
  is_charging = false
  is_upside_down = false
  enemy:start_walking()
end)

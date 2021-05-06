----------------------------------
--
-- Splitted Eye.
--
-- Splitted part of the Slime Eye.
-- Be projected away to the hero on the first start hen move with a random jump and occasionally a long jump to the hero.
-- Is vulnerable to sword and thrust attacks which will make it jump to the ceiling and stomp down.
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)
local map_tools = require("scripts/maps/map_tools")

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local camera = map:get_camera()
local sprite = enemy:create_sprite("enemies/boss/slime_eye/splitted_eye")
local quarter = math.pi * 0.5
local circle = math.pi * 2.0
local shadow
local is_projected = false
local is_hurt = false

-- Configuration variables
local projected_duration = 750
local waiting_minimum_duration = 500
local waiting_maximum_duration = 1500
local jumping_speed = 120
local jumping_height = 16
local jumping_duration = 500
local random_jump_probability = 0.8
local jump_to_ceiling_speed = 280
local waiting_on_ceiling_duration = 1000
local falling_duration = 750
local stunned_duration = 1000

-- Start a random jump and occasionally a long jump to the hero.
local function start_jumping()

  local is_random_jump = math.random() < random_jump_probability
  local jumping_strength = math.random() % 0.5 + 0.5 -- The jump is on a random strength, use the same ratio for height and duration.
  local duration = is_random_jump and jumping_duration * jumping_strength or jumping_duration
  local height = is_random_jump and jumping_height * jumping_strength or jumping_height
  local angle = is_random_jump and math.random() * circle or enemy:get_angle(hero)

  enemy:start_jumping(duration, height, angle, jumping_speed, function()
    enemy:restart()
  end)
  sprite:set_animation("jumping")
end

-- Start a high jump to the ceiling, then wait a few time and stomp down on the hero.
local function start_jump_to_ceiling()

  -- Start the jump to the ceiling.
  local _, y = enemy:get_position()
  local _, camera_y = camera:get_position()
  local movement = sol.movement.create("straight")
  movement:set_max_distance( y - camera_y)
  movement:set_angle(quarter)
  movement:set_speed(jump_to_ceiling_speed)
  movement:set_ignore_obstacles(true)
  movement:start(sprite)
  enemy:set_layer(map:get_max_layer())

  function movement:on_finished()
    enemy:set_can_attack(false)
    enemy:set_visible(false) -- Hide shadow.

    -- Wait a few time then stomp down on the hero.
    sol.timer.start(enemy, waiting_on_ceiling_duration, function()
      local x, y, layer = hero:get_position()
      sprite:set_xy(0, camera_y - y)
      shadow:set_position(x, y)
      enemy:set_position(x, y)
      enemy:set_visible()
      enemy:set_can_attack()
      enemy:start_throwing(enemy, falling_duration, y - camera_y, nil, nil, nil, function()
        enemy:set_layer(layer)
    
        -- Start a visual effect at the landing impact location, wait a few time and restart.
        map_tools.start_earthquake({count = 12, amplitude = 4, speed = 90})
        enemy:start_brief_effect("entities/effects/impact_projectile", "default", -12, 0)
        enemy:start_brief_effect("entities/effects/impact_projectile", "default", 12, 0)

        -- Stun the hero if not in the air.
        local is_hero_freezed = false
        if not hero:is_jumping() then
          is_hero_freezed = true
          hero:freeze()
          hero:get_sprite():set_animation("scared")
        end

        -- Wait for some time then unfreeze the hero if needed.
        sol.timer.start(hero, stunned_duration, function()
          if is_hero_freezed then
            hero:unfreeze()
          end
        end)

        enemy:restart()
      end)
    end)
  end
end

-- Check if the custom death as to be started before triggering the built-in hurt behavior.
local function hurt()

  if is_hurt then
    return
  end
  is_hurt = true
  enemy:set_hero_weapons_reactions({sword = "protected", thrust = "protected"})

  -- Custom die if no more life.
  if enemy:get_life() - 1 < 1 then

    -- Wait a few time, start 2 sets of explosions close from the enemy, wait a few time again and finally make the final explosion and enemy die.
    enemy:stop_all()
    enemy:start_death(function()
      sprite:set_animation("hurt")
      sol.timer.start(enemy, 1500, function()
        enemy:start_close_explosions(32, 2500, "entities/explosion_boss", 0, -13, function()
          sol.timer.start(enemy, 1000, function()
            enemy:start_brief_effect("entities/explosion_boss", nil, 0, -13)
            finish_death()
          end)
        end)
        sol.timer.start(enemy, 200, function()
          enemy:start_close_explosions(32, 2300, "entities/explosion_boss", 0, -13)
        end)
      end)
    end)
    return
  end

  -- Hurt normally then restart
  enemy:hurt(1)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(4)
  enemy:set_size(32, 24)
  enemy:set_origin(16, 21)
  shadow = enemy:start_shadow("enemies/boss/armos_knight/shadow")
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  -- Behavior for each items.
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
  	shield = "protected",
  	thrust = "protected",
  })

  -- States.
  sprite:set_xy(0, 0)
  enemy:set_can_attack(true)
  enemy:set_damage(4)
  enemy:set_layer_independent_collisions(true)
  if is_projected then
    if not is_hurt then
      enemy:set_hero_weapons_reactions({sword = hurt, thrust = hurt})
      sol.timer.start(enemy, math.random(waiting_minimum_duration, waiting_maximum_duration), function()
        start_jumping()
      end)
    else
      is_hurt = false
      start_jump_to_ceiling()
    end
  else
    is_projected = true
    enemy:start_jumping(projected_duration, jumping_height, hero:get_angle(enemy), jumping_speed, function()
      enemy:restart()
    end)
  end
end)

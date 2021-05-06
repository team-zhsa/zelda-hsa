----------------------------------
--
-- Armos Knight.
--
-- Armos like enemy immobile at start.
-- Wake up when the hero is close enough, then walk to the hero and regulary jump to him, making him frozen for some time on stomp down if the hero is not jumping.
-- The sword repulse without hurt unless the attack is a spin one.
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)
local map_tools = require("scripts/maps/map_tools")

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local hurt_shader = sol.shader.create("hurt")
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5
local is_awake = false
local is_pushed_back = false
local is_hurt = false
local step = 1

-- Configuration variables
local waking_up_distance = 40
local walking_speed = 44
local bouncing_height = 4
local jumping_speed = 88
local jumping_height = 32
local awakening_duration = 1000
local bouncing_duration = 200
local shaking_duration = 1500
local hurt_duration = 600
local walking_minimum_duration = 1000
local jumping_duration = 200
local on_air_duration = 600
local stompdown_duration = 50
local stunned_duration = 1000
local step_2_triggering_life = 7
local step_2_walking_speed = 55
local step_3_triggering_life = 3
local step_3_walking_speed = 66

-- Set the enemy step.
local function set_step(number, speed, sprite_suffix_name)

  step = number
  walking_speed = speed
  enemy:remove_sprite(sprite)
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "/" .. sprite_suffix_name)
end

-- Manually hurt the enemy to not trigger to hurt or death built-in behavior.
local function hurt(damage)

  if is_hurt then
    return
  end
  is_hurt = true

  -- Custom die if no more life.
  if enemy:get_life() - damage < 1 then

    -- Wait a few time, start 2 sets of explosions close from the enemy, wait a few time again and finally make the final explosion and enemy die.
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

  -- Manually hurt the enemy to not restart it automatically and let it finish its move or jump.
  enemy:set_life(enemy:get_life() - damage)
  sprite:set_shader(hurt_shader)
  if enemy.on_hurt then
    enemy:on_hurt()
  end

  -- Check if the step has to be changed after a hurt.
  sol.timer.start(map, hurt_duration, function()
    is_hurt = false
    sprite:set_shader(nil)
    if step == 1 and enemy:get_life() <= step_2_triggering_life then
      set_step(2, step_2_walking_speed, "step_2")
    end
    if step == 2 and enemy:get_life() <= step_3_triggering_life then
      set_step(3, step_3_walking_speed, "step_3")
    end
  end)
end

-- Only hurt the enemy if the sword attack is a spin attack, else push the hero back.
local function on_sword_attack_received()

  if hero:get_sprite():get_animation() == "spin_attack" then
    hurt(2)
  end
  if not is_pushed_back then
    is_pushed_back = true
    enemy:start_pushed_back(hero, 250, 150, sprite, nil, function()
      is_pushed_back = false
    end)
  end
end

-- Make the enemy jump and stomp down.
local function start_jumping()

  -- Start jumping to the current hero position.
  local target_x, target_y, _ = hero:get_position()
  local movement = sol.movement.create("target")
  movement:set_speed(jumping_speed)
  movement:set_target(target_x, target_y)
  movement:set_smooth(false)
  movement:start(enemy)
  enemy:start_flying(jumping_duration, jumping_height, function()

    -- Wait for a delay and start the stomp down.
    movement:stop()
    sol.timer.start(enemy, on_air_duration, function()
      enemy:stop_flying(stompdown_duration, function()

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

        -- Wait for some time then unfreeze the hero if needed and restart the enemy.
        sol.timer.start(enemy, stunned_duration, function()
          if is_hero_freezed then
            hero:unfreeze()
          end
          enemy:restart()
        end)
      end)
    end)
  end)
end

-- Start the enemy movement.
local function start_walking()

  sprite:set_animation("walking")
  local movement = enemy:start_target_walking(hero, walking_speed)
  local is_walking_duration_elapsed = false

  -- Bounce on the ground while moving.
  local function bounce()
    enemy:start_jumping(bouncing_duration, bouncing_height, nil, nil, function()
      if is_walking_duration_elapsed then
        movement:stop()
        start_jumping()
      else
        bounce()
      end
    end)
  end
  bounce()

  -- Walk for some time then start a jump at the end of the current jump.
  sol.timer.start(enemy, walking_minimum_duration, function()
    is_walking_duration_elapsed = true
  end)
end

-- Make the enemy wake up then start walking.
local function start_waking_up()

  is_awake = true
  sprite:set_animation("awakening")
  sol.timer.start(enemy, awakening_duration, function()
    sprite:set_animation("shaking")
    sol.timer.start(enemy, shaking_duration, function()
      enemy:restart()
    end)
  end)
end

-- Wait for the hero to be near enough before wake the enemy up.
local function start_sleeping()

  sprite:set_animation("stopped")
  sol.timer.start(enemy, 10, function()
    if not enemy:is_near(hero, waking_up_distance) then
      return true
    end
    start_waking_up()
    return
  end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(12)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:start_shadow("enemies/" .. enemy:get_breed() .. "/shadow")
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = is_awake and function() hurt(1) end or "protected",
  	boomerang = "protected",
  	explosion = "ignored",
  	sword = is_awake and on_sword_attack_received or "protected",
  	thrown_item = "protected",
  	fire = "protected",
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = "protected",
  	magic_powder = "ignored",
  	shield = "protected",
  	thrust = "protected"
  })

  -- States.
  enemy:set_can_attack(true)
  enemy:set_damage(4)
  if is_awake then
    enemy:set_traversable(true)
    start_walking()
  else
    enemy:set_invincible()
    start_sleeping()
  end
end)

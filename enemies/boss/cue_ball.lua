----------------------------------
--
-- Cue Ball.
--
-- Charge to a direction 4 and turn right on obstacle reached.
-- Spin around himself on hurt, and charge to a random direction.
--
-- Methods : enemy:start_charging([direction4])
--           enemy:start_spinning()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local splash_sprite
local hurt_frame_delay = sprite:get_frame_delay("hurt")
local quarter = math.pi * 0.5
local circle = math.pi * 2.0
local step = 1
local is_hurt = false

-- Configuration variables
local charging_angles = {0, quarter, 2.0 * quarter, 3.0 * quarter}
local charging_speed = 160
local waiting_duration = 500
local spinning_minimum_duration = 500
local spinning_maximum_duration = 1000
local front_angle = 2.0 * math.pi / 3.0

-- Get the upper-left grid node coordinates of the enemy position.
local function get_grid_position()

  local position_x, position_y, _ = enemy:get_position()
  return position_x - position_x % 8, position_y - position_y % 8
end

-- Hurt the enemy if hero is not on his front.
local function on_attack_received()

  -- Don't hurt if a previous hurt animation is still running.
  if is_hurt then
    return
  end

  -- Hurt the hero instead of the enemy if the hero is in front of him.
  if enemy:is_entity_in_front(hero, front_angle) then
    hero:start_hurt(enemy:get_damage())
    return
  end
  is_hurt = true

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

  -- Freeze the hero for some time if running.
  if hero:is_running() then
    hero:freeze()
    sol.timer.start(hero, 300, function()
      hero:unfreeze()
    end)
  end

  -- Manually hurt to not trigger the built-in behavior and start spinning instead.
  enemy:set_life(enemy:get_life() - 1)
  enemy:start_spinning()
  step = (math.random(2) == 1) and -1 or 1
  if enemy.on_hurt then
    enemy:on_hurt()
  end
end

-- Start the enemy movement.
function enemy:start_charging(direction4)

  direction4 = direction4 or sprite:get_direction()
  splash_sprite:set_animation("walking")
  enemy:start_straight_walking(charging_angles[direction4 + 1], charging_speed, nil, function()
    sprite:set_animation("stopped")
    splash_sprite:stop_animation()
    sol.timer.start(enemy, waiting_duration, function()
      enemy:start_charging((direction4 - step) % 4)
    end)
  end)
end

-- Start spinning around himself for some time then start charging on the last direction of the spin.
function enemy:start_spinning()

  sprite:set_animation("hurt")
  sol.timer.stop_all(enemy)
  enemy:stop_movement()

  local spinning_timer = sol.timer.start(enemy, hurt_frame_delay, function()
    local frame = sprite:get_frame()
    sprite:set_direction((sprite:get_direction() - 1) % 4)
    sprite:set_frame(frame)
    return true
  end)
  sol.timer.start(enemy, math.random(spinning_minimum_duration, spinning_maximum_duration), function()
    is_hurt = false
    spinning_timer:stop()
    enemy:start_charging()
  end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(8)
  enemy:set_size(48, 48)
  enemy:set_origin(24, 24)
  enemy:set_position(get_grid_position()) -- Set the position to the center of the current 16*16 case instead of 8, 13.
  enemy:start_shadow("enemies/boss/cue_ball/shadow")
  enemy:set_drawn_in_y_order(false) -- Display the enemy as a flat entity.
  enemy:bring_to_front()

  -- Add the splash effect as sub entity to not hurt the hero.
  local x, y, layer = enemy:get_position()
  local splash = map:create_custom_entity({
    name = (enemy:get_name() or enemy:get_breed()) .. "_splash_effect",
    direction = sprite:get_direction(),
    x = x,
    y = y,
    layer = layer,
    width = 48,
    height = 48,
    sprite = "enemies/" .. enemy:get_breed() .. "/splash_effect"
  })
  enemy:start_welding(splash)
  splash:set_traversable_by(true)
  splash:set_drawn_in_y_order(false) -- Display the sub enemy as a flat entity.
  splash:bring_to_back()
  splash_sprite = splash:get_sprite()
  sprite:register_event("on_direction_changed", function(sprite)
    splash_sprite:set_direction(sprite:get_direction())
  end)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = "protected",
  	boomerang = "protected",
  	explosion = "ignored",
  	sword = on_attack_received,
  	thrown_item = "protected",
  	fire = "protected",
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = "protected",
  	magic_powder = "ignored",
  	shield = "protected",
  	thrust = on_attack_received
  })

  -- States.
  is_hurt = false
  enemy:set_obstacle_behavior("flying") -- Able to walk over water and lava.
  enemy:set_can_attack(true)
  enemy:set_damage(4)
  enemy:start_charging(0)
end)

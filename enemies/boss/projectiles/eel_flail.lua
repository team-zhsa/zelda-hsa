----------------------------------
--
-- Slime Eel's Flail.
--
-- Tail of the Slime Eel with a spiked ball at the end, used as a flail.
-- The flail turn around itself, successively slow down to arm a strike, then speed up to actually strike.
-- Can be manually pulled in ground by a length value where it stop its movement for some time, then manually rising to go back to its initial length and strike again.
--
-- Methods : enemy:start_appearing()
--           enemy:start_pulled(length, speed)
--           enemy:start_rising()
--
----------------------------------

-- Global variables.
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprites = {}
local quarter = math.pi * 0.5
local circle = math.pi * 2.0
local striking_timer
local revolution_angle = quarter
local strike_angle = 0
local rotation_ratio = 1

-- Configuration variables.
local tail_parts_number = 5
local tail_parts_distance = {16, 36, 52, 68, 84}
local tail_revolution_time = 5000
local tail_strike_time = 1500

-- Start the regular tail movement.
local function start_regular_movement(initial_angle, initial_strike_angle)

  rotation_ratio = rotation_ratio == 1 and -1 or 1 -- Reverse the rotation sense.

  local revolution_time = initial_angle / circle * tail_revolution_time
  local strike_time = initial_strike_angle / circle * tail_strike_time
  striking_timer = sol.timer.start(enemy, 10, function()

    -- Compute the normal circular angle, and a sinus variation to apply on it to simulate the striking.
    revolution_time = (revolution_time + 10 * rotation_ratio) % tail_revolution_time
    revolution_angle = revolution_time / tail_revolution_time * circle
    strike_time = (strike_time + 10 * rotation_ratio) % tail_strike_time
    strike_angle = math.sin(strike_time / tail_strike_time * circle) * 1.5

    -- Set sprite positions where the further the sprite is, the more the striking variation is fully applied.
    for i = 1, tail_parts_number, 1 do
      local angle = revolution_angle - tail_parts_distance[i] / tail_parts_distance[tail_parts_number] * strike_angle
      sprites[i]:set_xy(tail_parts_distance[i] * math.cos(angle), -tail_parts_distance[i] * math.sin(angle))
    end
    return true
  end)
end

-- Make the start animation of the enemy.
enemy:register_event("start_appearing", function(enemy)

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
    thrust = "protected"
  })
  enemy:set_can_attack(true)
  enemy:set_visible()

  enemy:start_rising()
end)

-- Pull the tail onto the ground.
enemy:register_event("start_pulled", function(enemy, length, speed)

  local time = 0
  local duration = length / speed * 1000
  striking_timer:stop()
  sol.timer.start(enemy, 10, function()
    time = time + 10

    -- Set sprite positions and hide ones that are on the exact enemy position.
    for i = 1, tail_parts_number, 1 do
      local angle = revolution_angle - tail_parts_distance[i] / tail_parts_distance[tail_parts_number] * strike_angle
      local distance = tail_parts_distance[i] - speed * time * 0.001

      if distance > 0 then
        sprites[i]:set_xy(distance * math.cos(angle), -distance * math.sin(angle))
      else
        sprites[i]:set_opacity(0)
      end
    end

    if time <= duration then
      return true
    end
  end)
end)

-- Make the tail goes back to its fighting position.
enemy:register_event("start_rising", function(enemy)

  start_regular_movement(revolution_angle, strike_angle)
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_size(32, 32)
  enemy:set_origin(16, 29)
  enemy:set_visible(false)

  -- Create the tail sprites.
  sprites[1] = enemy:create_sprite("enemies/boss/slime_eel/body")
  sprites[1].base_animation = "base"
  for i = 2, tail_parts_number - 1, 1 do
    sprites[i] = enemy:create_sprite("enemies/boss/slime_eel/body")
    sprites[i].base_animation = "body"
  end
  sprites[tail_parts_number] = enemy:create_sprite("enemies/boss/slime_eel/body")
  sprites[tail_parts_number].base_animation = "tail"
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_invincible()
  enemy:set_damage(4)
  enemy:set_can_attack(false)
  enemy:set_obstacle_behavior("flying") -- Don't fall in holes.
  enemy:set_pushed_back_when_hurt(false)
  for i = 1, tail_parts_number, 1 do
    sprites[i]:set_animation(sprites[i].base_animation)
  end
end)

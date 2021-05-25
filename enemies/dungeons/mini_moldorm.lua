----------------------------------
--
-- Mini Moldorm.
--
-- Caterpillar enemy with one body part and one tail that will follow the head move.
-- Moves in curved motion, and randomly change the direction of the curve.
--
-- Methods : enemy:start_walking()
--
----------------------------------

-- Global variables
local enemy = ...
local common_actions = require("enemies/lib/common_actions")
require("scripts/multi_events")

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local head_sprite, body_sprite, tail_sprite
local last_positions, frame_count
local walking_movement = nil
local sixteenth = math.pi * 0.125
local eighth = math.pi * 0.25
local quarter = math.pi * 0.5
local circle = math.pi * 2.0

-- Configuration variables
local walking_speed = 88
local walking_angle = 0.05
local body_frame_lag = 11
local tail_frame_lag = 20
local keeping_angle_duration = 1000

local highest_frame_lag = tail_frame_lag + 1 -- Avoid too much values in the last_positions table

-- Start the enemy movement.
function enemy:start_walking()

  walking_movement = sol.movement.create("straight")
  walking_movement:set_speed(walking_speed)
  walking_movement:set_angle(math.random(4) * quarter)
  walking_movement:set_smooth(false)
  walking_movement:start(enemy)

  -- Take the obstacle normal as angle on obstacle reached.
  function walking_movement:on_obstacle_reached()
    walking_movement:set_angle(enemy:get_obstacles_normal_angle(walking_movement:get_angle()))
  end

  -- Slightly change the angle when walking.
  function walking_movement:on_position_changed()
    local angle = walking_movement:get_angle() % circle
    if walking_movement == enemy:get_movement() then
      walking_movement:set_angle(angle + walking_angle)
    end
  end

  -- Regularly and randomly change the angle.
  sol.timer.start(enemy, keeping_angle_duration, function()
    if math.random(2) == 1 then
      walking_angle = 0 - walking_angle
    end
    return true
  end)
end

-- Update head, body and tails sprite on position changed whatever the movement is.
enemy:register_event("on_position_changed", function(enemy)

  if not last_positions then
    return -- Workaround : Avoid this event to be called before enemy is actually started by the engine.
  end

  -- Save current position
  local x, y, _ = enemy:get_position()
  last_positions[frame_count] = {x = x, y = y}

  -- Set the head sprite direction.
  local direction8 = math.floor((enemy:get_movement():get_angle() + sixteenth) % circle / eighth)
  if head_sprite:get_direction() ~= direction8 then
    head_sprite:set_direction(direction8)
  end

  -- Replace part sprites on a previous position.
  local function replace_part_sprite(sprite, frame_lag)
    local previous_position = last_positions[(frame_count - frame_lag) % highest_frame_lag] or last_positions[0]
    sprite:set_xy(previous_position.x - x, previous_position.y - y)
  end
  replace_part_sprite(body_sprite, body_frame_lag)
  replace_part_sprite(tail_sprite, tail_frame_lag)

  frame_count = (frame_count + 1) % highest_frame_lag
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  common_actions.learn(enemy, sprite)
  enemy:set_life(2)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 8)
  
  -- Create sprites in right z-order.
  tail_sprite = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "/tail")
  body_sprite = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "/body")
  head_sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

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

  -- States.
  last_positions = {}
  frame_count = 0
  enemy:set_can_attack(true)
  enemy:set_damage(1)
  enemy:start_walking()
end)

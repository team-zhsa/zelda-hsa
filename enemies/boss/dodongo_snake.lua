----------------------------------
--
-- Dodongo Snake.
--
-- Caterpillar enemy with one body part that will follow the head move.
-- Randomly moves over horizontal and vertical axis, and can only turn left or right once a movement finished.
-- Can only be hurt by eating a bomb if it collide the center of the head.
-- 
--
-- Methods : enemy:start_walking()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local head_sprite, body_sprite
local last_positions = {}
local frame_count = 0
local quarter = math.pi * 0.5

-- Configuration variables
local walking_angles = {0, quarter, 2.0 * quarter, 3.0 * quarter}
local walking_speed = 24
local walking_minimum_duration = 1000
local walking_maximum_duration = 2000
local body_frame_lag = 50
local bomb_eating_duration = 1000

local highest_frame_lag = body_frame_lag + 1 -- Avoid too much values in the last_positions table

-- Return the given table minus sprite direction and its opposite.
local function get_possible_moving_angles(angles)

  local possible_angles = {}
  local sprite_direction = head_sprite:get_direction()
  for index, angle in ipairs(angles) do
    if (index - 1) % 2 ~= sprite_direction % 2 then
      possible_angles[#possible_angles + 1] = angle
    end
  end
  return possible_angles
end

-- Update body sprite depending on previous head positions.
local function update_body_sprite()

  -- Save current position
  local x, y, _ = enemy:get_position()
  last_positions[frame_count] = {x = x, y = y}

  -- Replace body sprite on a previous position.
  local previous_position = last_positions[(frame_count - body_frame_lag) % highest_frame_lag] or last_positions[0]
  body_sprite:set_xy(previous_position.x - x, previous_position.y - y)

  frame_count = (frame_count + 1) % highest_frame_lag
end

-- Eat the given bomb.
local function eat_bomb(bomb)

  enemy:stop_movement()
  sol.timer.stop_all(enemy)
  bomb:remove()
  head_sprite:set_animation("bomb_eating", function()
    head_sprite:set_animation("immobilized")

    -- Eat and die if no more life
    if enemy:get_life() == 1 then
      enemy:bring_sprite_to_front(body_sprite)
      body_sprite:set_animation("dying",function()
        local x, y = body_sprite:get_xy()
        enemy:start_brief_effect("entities/explosion_boss", nil, x, y)
        enemy:start_death()
      end)
      return
    end

    -- Else eat and start hurt animation.
    body_sprite:set_animation("bomb_eating")
    sol.timer.start(enemy, bomb_eating_duration, function()
      enemy:bring_sprite_to_front(body_sprite) -- Make the body displayed over the head just for this animation.
      body_sprite:set_animation("exploding", function()
        enemy:bring_sprite_to_back(body_sprite)
        local angle = head_sprite:get_direction() * quarter
        local effect_x = math.cos(angle) * 16
        local effect_y = -math.sin(angle) * 16
        enemy:start_brief_effect("entities/effects/brake_smoke", "default", effect_x, effect_y)
        enemy:hurt(1)
      end)
    end)
  end)
end

-- Start the enemy movement.
function enemy:start_walking()

  local angles = get_possible_moving_angles(walking_angles)
  enemy:start_straight_walking(angles[math.random(#angles)], walking_speed)

  sol.timer.start(enemy, 10, function()
    update_body_sprite()
    return true
  end)

  -- Use time instead of distance for walking step to let the enemy go against a wall for some time.
  sol.timer.start(enemy, math.random(walking_minimum_duration, walking_maximum_duration), function()
    enemy:restart()
  end)
end

-- Passive behaviors needing constant checking.
enemy:register_event("on_update", function(enemy)

  -- Eat the bomb when the bomb sprite hit the center of the head.
  for entity in map:get_entities_in_region(enemy) do
    if entity:get_type() == "custom_entity" and entity:get_model() == "bomb" and enemy:overlaps(entity, "center") then
      local x, y = entity:get_sprite():get_xy()
      if x == 0 and y == 0 then -- Only eat a bomb on the floor.
        eat_bomb(entity)
      end
    end
  end
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(3)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)

  body_sprite = enemy:create_sprite("enemies/" .. enemy:get_breed() .. "/body")
  head_sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_invincible()

  -- States.
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_can_attack(true)
  enemy:set_damage(4)
  enemy:start_walking()
end)

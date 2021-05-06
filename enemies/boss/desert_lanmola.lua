----------------------------------
--
-- Desert Lanmola.
--
-- Caterpillar enemy that can have any number of body parts that will follow the head move.
-- Wait a few time then leaps out the ground, do a curved fly with two bump and dive into the ground again.
-- Don't restart on hurt to let the move end, and explode part by part on die.
--
-- Methods : enemy:start_tunneling()
--           enemy:appear()
--           enemy:disappear()
--           enemy:wait()
--
----------------------------------

-- Global variables
local enemy = ...
local common_actions = require("enemies/lib/common_actions")
common_actions.learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local camera = map:get_camera()
local parts = {}
local head_sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local last_positions, frame_count
local tunnel, appearing_dust, disappearing_dust

-- Configuration variables
local tied_parts_frame_lags = {15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180, 195, 210, 225, 240, 255, 270, 285, 300}
local tunnel_duration = 1000
local waiting_minimum_duration = 2000
local waiting_maximum_duration = 4000
local jumping_speed = 48
local jumping_height = 32
local jumping_minimum_duration = 2700
local jumping_maximum_duration = 3000
local angle_amplitude_from_center = math.pi * 0.125
local hurt_duration = 600

-- Constants
local parts_count = #tied_parts_frame_lags + 1
local tail_frame_lag = tied_parts_frame_lags[#tied_parts_frame_lags]
local highest_frame_lag = tail_frame_lag + 1
local eighth = math.pi * 0.25
local sixteenth = math.pi * 0.125
local circle = math.pi * 2.0

-- Return a random visible position.
local function get_random_visible_position()

  local x, y, width, height = camera:get_bounding_box()
  return math.random(x, x + width), math.random(y, y + height)
end

-- Remove dust and tunnel effects.
local function remove_effects()

  local function remove_effect(effect)
    if effect and effect:exists() then
      effect:remove()
    end
  end
  remove_effect(tunnel)
  remove_effect(appearing_dust)
  remove_effect(disappearing_dust)
end

-- Echo some of the reference_sprite events and methods to the given sprite.
local function synchronize_sprite(sprite, reference_sprite)

  sprite:synchronize(reference_sprite)
  reference_sprite:register_event("on_direction_changed", function(reference_sprite)
    sprite:set_direction(reference_sprite:get_direction())
  end)
  reference_sprite:register_event("on_animation_changed", function(reference_sprite, name)
    if sprite:has_animation(name) then
      sprite:set_animation(name)
    end
  end)
end

-- Return a table with only visible sprites and without the head, sorted from tail to head.
local function get_exploding_tied_parts()

	local exploding_parts = {}
	for i = parts_count, 2, -1 do
    if parts[i]:is_visible() then
  		exploding_parts[#exploding_parts + 1] = parts[i]
    end
	end
  return exploding_parts
end

-- Make the visible enemy parts explode one after the other in the given order, and remove exploded ones.
local function start_part_explosions(on_finished_callback)

  parts = get_exploding_tied_parts()

  -- Start chained explosion.
  local function start_part_explosion(index)
    local part = parts[index]
    local sprite_x, sprite_y = part:get_sprite():get_xy()
    local explosion = part:start_brief_effect("entities/explosion_boss", nil, sprite_x, sprite_y, nil, function()
      if index < #parts then
        start_part_explosion(index + 1)
      else
        if on_finished_callback then
          on_finished_callback()
        end
      end
    end)
    explosion:set_layer(map:get_max_layer())
    part:remove()
  end
  start_part_explosion(1)
end

-- Update body and tail sub entities position and offset.
local function update_tied_parts_position()

  -- Save current head sprite position and offset if it is still visible.
  local x, y, _ = enemy:get_position()
  local x_offset, y_offset = head_sprite:get_xy()
  if enemy:is_visible() then
    last_positions[frame_count] = {x = x, y = y, x_offset = x_offset, y_offset = y_offset}
  else
    last_positions[frame_count] = nil
  end

  -- Replace tied entities on a previous position.
  local function replace_part(part, frame_lag)
    local key = (frame_count - frame_lag) % highest_frame_lag
    if last_positions[key] then
      part:set_position(last_positions[key].x, last_positions[key].y)
      part:get_sprite():set_xy(last_positions[key].x_offset, last_positions[key].y_offset)
    end

    -- Make parts with a position visible and ones with no position invisible.
    local is_visible = last_positions[key] ~= nil
    if part:is_visible() and not is_visible or not part:is_visible() and is_visible then
      part:set_visible(is_visible)
      part:set_can_attack(is_visible)
    end
  end
  for i = 2, parts_count do
    replace_part(parts[i], tied_parts_frame_lags[i - 1])
  end

  frame_count = (frame_count + 1) % highest_frame_lag
end

-- Create a tied part with its shadow.
local function create_tied_part(sprite_suffix_name)

  local x, y, layer = enemy:get_position()
  local sub_enemy = map:create_enemy({
    name = (enemy:get_name() or enemy:get_breed()) .. "_" .. sprite_suffix_name,
    breed = "empty", -- Workaround: Breed is mandatory but a non-existing one seems to be ok to create an empty enemy though.
    x = x,
    y = y,
    layer = layer,
    direction = head_sprite:get_direction()
  })
  sub_enemy:set_visible(false)
  sub_enemy:set_invincible()
  sub_enemy:set_damage(enemy:get_damage())
  sub_enemy:set_can_attack(false)
  common_actions.learn(sub_enemy) -- Workaround: Learn common_actions to the sub enemy to get shadow and welding functions.
  sub_enemy:start_shadow()

  -- Echo some of the main enemy methods
  enemy:register_event("on_removed", function(enemy)
    if sub_enemy:exists() then
      sub_enemy:remove()
    end
  end)
  enemy:register_event("on_enabled", function(enemy)
    sub_enemy:set_enabled()
  end)
  enemy:register_event("on_disabled", function(enemy)
    sub_enemy:set_enabled(false)
  end)
  enemy:register_event("on_dead", function(enemy)
    if sub_enemy:exists() then
      sub_enemy:remove()
    end
  end)

  -- Create the sub enemy sprite, and synchronize it on the body one.
  local sub_sprite = sub_enemy:create_sprite("enemies/" .. enemy:get_breed() .. "/" .. sprite_suffix_name)
  synchronize_sprite(sub_sprite, head_sprite)

  return sub_enemy
end

-- Manually hurt the enemy to not restart it automatically and let it finish its move.
local function hurt(damage)

  -- Don't hurt if a previous hurt animation is still running.
  if head_sprite:get_animation() == "hurt" then
    return
  end

  -- Custom die if no more life.
  if enemy:get_life() - damage < 1 then
    
    -- Wait a few time, make visible tied sprites explode from tail to head, wait a few time again and finally make the head explode and enemy die.
    enemy:start_death(function()
      for _, part in pairs(parts) do
        part:stop_all()
      end
      remove_effects()
      head_sprite:set_animation("hurt")
      sol.timer.start(enemy, 2000, function()
        start_part_explosions(function()
          sol.timer.start(enemy, 1000, function()
            local x, y = head_sprite:get_xy()
            enemy:start_brief_effect("entities/explosion_boss", nil, x, y)
            set_treasure_falling_height(-y)
            finish_death()
          end)
        end)
      end)
    end)
    return
  end

  -- Manually hurt else to not trigger the built-in behavior and its automatic restart.
  enemy:set_life(enemy:get_life() - damage)
  head_sprite:set_animation("hurt")
  if enemy.on_hurt then
    enemy:on_hurt()
  end

  sol.timer.start(enemy, hurt_duration, function()
    head_sprite:set_animation("walking")
  end)
end

-- Create a tunnel and appear at a random position.
function enemy:start_tunneling()

  -- Postpone to the next frame if the random position would be over an obstacle.
  local x, y, _ = enemy:get_position()
  local random_x, random_y = get_random_visible_position()
  if enemy:test_obstacles(random_x - x, random_y - y) then
    sol.timer.start(enemy, 10, function()
      enemy:start_tunneling()
    end)
    return
  end

  for _, part in pairs(parts) do
    part:set_position(random_x, random_y)
  end
  tunnel = enemy:start_brief_effect("enemies/" .. enemy:get_breed() .. "/dust", "tunnel", 0, 0, tunnel_duration)
  sol.timer.start(enemy, tunnel_duration, function()
    enemy:appear()  -- Start a timer on the enemy instead of using tunnel:on_finished() to avoid continue if the enemy was disabled from outside this script.
  end)
end

-- Start leaps out the ground and fly.
function enemy:appear()

  -- Target a random point at the opposite side of the room.
  local region_x, region_y, region_width, region_height = camera:get_bounding_box()
  local angle_variance = math.random() * angle_amplitude_from_center * 2 - angle_amplitude_from_center
  local angle = enemy:get_angle(region_x + region_width / 2.0, region_y + region_height / 2.0) + angle_variance
  local movement = enemy:start_straight_walking(angle, jumping_speed)
  local direction8 = math.floor((angle + sixteenth) % circle / eighth)

  -- Schedule an update of the head sprite vertical offset by frame.
  local duration = math.random(jumping_minimum_duration, jumping_maximum_duration)
  local elapsed_time = 0
  sol.timer.start(enemy, 10, function()

    update_tied_parts_position()
    elapsed_time = elapsed_time + 10
    if elapsed_time < duration then
      local progress = elapsed_time / duration
      head_sprite:set_xy(0, -(0.913 * math.sqrt(math.sin(progress * math.pi)) + 0.35 * math.sin(math.sin(3 * progress * math.pi))) * jumping_height) -- Curve with two bumps.
      return true
    end
    if movement and enemy:get_movement() == movement then
      movement:stop()
    end
    enemy:disappear()
  end)

  -- Properties and effects.
  enemy:set_visible()
  head_sprite:set_direction(direction8)
  appearing_dust = enemy:start_brief_effect("enemies/" .. enemy:get_breed() .. "/dust", "projections", 0, 0, tail_frame_lag * 10 + 150)
  appearing_dust:bring_to_back()

  enemy:set_hero_weapons_reactions({
  	arrow = function() hurt(4) end,
  	boomerang = "protected",
  	explosion = "ignored",
  	sword = function() hurt(1) end,
  	thrown_item = "protected",
  	fire = "protected",
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = "protected",
  	magic_powder = "ignored",
  	shield = "protected",
  	thrust = function() hurt(2) end
  })
  enemy:set_can_attack(true)
end

-- Make enemy disappear in the ground.
function enemy:disappear()

  -- Start disappearing effects.
  enemy:set_visible(false)
  enemy:set_invincible()
  enemy:set_can_attack(false)
  disappearing_dust = enemy:start_brief_effect("enemies/" .. enemy:get_breed() .. "/dust", "projections", 0, 0, tail_frame_lag * 10 + 150)
  disappearing_dust:bring_to_back()

  -- Continue an extra loop of last_positions update to make the whole body.
  local elapsed_frames = 0
  sol.timer.start(enemy, 10, function()
    update_tied_parts_position()
    elapsed_frames = elapsed_frames + 1
    if elapsed_frames < tail_frame_lag then
      return true
    end
    enemy:restart()
  end)
end

-- Wait a few time and appear.
function enemy:wait()

  sol.timer.start(enemy, math.random(waiting_minimum_duration, waiting_maximum_duration), function()
    if not camera:overlaps(enemy:get_max_bounding_box()) then
      return true
    end
    enemy:start_tunneling()
  end)
end

-- Remove effects on disabled.
enemy:register_event("on_disabled", function(enemy)
  remove_effects()
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(8)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:start_shadow() -- Head shadow.
  parts[1] = enemy -- Add the enemy as first part since it symbolize the head.

  -- Created all body parts as separated entities because of y drawn orders, hurtless when invisible and easily attach a shadow.
  for i = 2, parts_count - 1 do
    table.insert(parts, create_tied_part("body"))
  end
  table.insert(parts, create_tied_part("tail"))
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  -- States.
  last_positions = {}
  frame_count = 0
  for _, part in pairs(parts) do
    part:set_visible(false)
    part:set_invincible()
    part:set_can_attack(false)
    part:set_damage(4)
    part:set_obstacle_behavior("flying")
  end
  enemy:stop_movement()
  enemy:set_layer_independent_collisions(true)
  enemy:set_pushed_back_when_hurt(false)
  enemy:wait()
end)

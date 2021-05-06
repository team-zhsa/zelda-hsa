----------------------------------
--
-- Turtle Rock.
--
-- Enemy that starts immobile, invincible and hurtless until enemy:start_awakening() is called from the outside.
-- Start swinging from left to right once wake up and attacks from time to time at the end of a movement.
--
-- Methods : start_awakening()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)
local map_tools = require("scripts/maps/map_tools")

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local top_wall, bottom_wall
local quarter = math.pi * 0.5
local neck_entities = {}
local initial_position = {}
local current_step
local is_awake = false
local is_hurt = false

-- Configuration variables
local earthquake_duration = 1500
local shaking_duration = 1000
local awake_duration = 500
local after_positioned_duration = 600
local after_swing_duration = 300
local after_attack_duration = 500
local hurt_duration = 600
local awakening_speed = 22
local swinging_speed = 44
local attacking_speed = 160
local attacking_maximum_distance = 100
local attacking_probability = 0.6
local base_offset = {x = 0, y = 25}
local swinging_offsets = {{x = 50, y = 25}, {x = -50, y = 25}}
local neck_entities_number = 7

-- Create a neck part
local function create_neck_sub_entity(sprite_suffix_name)

  local sub_enemy = map:create_enemy({
    name = (enemy:get_name() or enemy:get_breed()) .. "_" .. sprite_suffix_name,
    breed = "empty", -- Workaround: Breed is mandatory but a non-existing one seems to be ok to create an empty enemy though.
    x = initial_position.x,
    y = initial_position.y,
    layer = initial_position.layer,
    width = 16,
    height = 16,
    direction = sprite:get_direction()
  })
  sub_enemy:set_drawn_in_y_order(false) -- Display the sub enemy as a flat entity.
  sub_enemy:bring_to_back()
  sub_enemy:create_sprite("enemies/" .. enemy:get_breed() .. "/" .. sprite_suffix_name)

  sub_enemy:set_traversable(false) -- Make neck entity not traversable.
  sub_enemy:set_invincible()
  sub_enemy:set_attacking_collision_mode("touching")
  sub_enemy:set_damage(enemy:get_damage())

  return sub_enemy
end

-- Make the enemy sleep and wait for the hero to wake up.
local function start_sleeping()

  enemy:set_invincible()
  enemy:set_can_attack(false)
  enemy:set_traversable(false)
  sprite:set_animation("sleeping")
end

-- Make the enemy go from sleeping position to fighting position
local function start_positioning(speed)

  local distance = enemy:get_distance(initial_position.x + base_offset.x, initial_position.y + base_offset.y)
  local angle = enemy:get_angle(initial_position.x + base_offset.x, initial_position.y + base_offset.y)
  local movement = enemy:start_straight_walking(angle, speed, distance, function()
    sol.timer.start(enemy, after_positioned_duration, function()
      enemy:restart()
    end)
  end)
  movement:set_ignore_obstacles()
end

-- Make the enemy pounce on the hero.
local function start_attacking()

  -- Forbid angles between 0 and math.pi for the attack.
  local angle = enemy:get_angle(hero)
  if angle > 0.0 and angle <= quarter then
    angle = 0.0
  end
  if angle > quarter and angle < math.pi then
    angle = math.pi
  end

  sprite:set_animation("attacking")
  local distance = math.min(attacking_maximum_distance, enemy:get_distance(hero))
  local movement = enemy:start_straight_walking(angle, attacking_speed, distance, function()
    sol.timer.start(enemy, after_attack_duration, function()
      start_positioning(swinging_speed)
    end)
  end)
  movement:set_ignore_obstacles()
end

-- Make the enemy move to the step offset and randomly attack at the end of the movement.
local function start_swinging(step_number)

  is_swinging = true

  -- Skip to next step if the enemy is already on the requested step position.
  local step = swinging_offsets[step_number]
  local x, y = enemy:get_position()
  local target_x, target_y = initial_position.x + step.x, initial_position.y + step.y
  local angle = enemy:get_angle(target_x, target_y)
  local distance = enemy:get_distance(target_x, target_y)
  
  sprite:set_animation("awake")
  current_step = step_number
  local movement = enemy:start_straight_walking(angle, swinging_speed, distance, function()
    sol.timer.start(enemy, after_swing_duration, function()
      if math.random() < attacking_probability then
        is_swinging = false
        start_attacking()
      else
        start_swinging((step_number % #swinging_offsets) + 1)
      end
    end)
  end)
  movement:set_ignore_obstacles()
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

  -- Manually hurt the enemy to briefly stop him and let it finish its move or attack without the automatic restart.
  enemy:set_life(enemy:get_life() - damage)
  local movement = enemy:get_movement()
  if movement then
    movement:stop()
  end
  sol.timer.stop_all(enemy)
  sprite:set_animation("hurt")
  if enemy.on_hurt then
    enemy:on_hurt()
  end
  
  -- Continue the swinging movement after the hurt if it was running, else go back to initial position.
  sol.timer.start(enemy, hurt_duration, function()
    is_hurt = false
    sprite:set_animation("awake")
    if is_swinging then
      start_swinging(current_step)
    else
      start_positioning(swinging_speed)
    end
  end)
end

-- Make the enemy wake up and move a bit forward.
function enemy:start_awakening()

  is_awake = true

  -- Start earthquake then awake animation.
  hero:freeze()
  map_tools.start_earthquake({count = 12, amplitude = 4, speed = 90})
  sol.timer.start(map, earthquake_duration, function()
    hero:unfreeze()
    sprite:set_animation("resuscitating", function()
      sprite:set_animation("shaking")
      sol.timer.start(enemy, shaking_duration, function()
        sprite:set_animation("awakening", function()
          sprite:set_animation("awake")
          sol.timer.start(enemy, awake_duration, function()
          sprite:set_animation("back_to_sleep", function()
            sprite:set_animation("awakening")
              sprite:set_animation("awake")
              sol.timer.start(enemy, awake_duration, function()
                start_positioning(awakening_speed)
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end

-- Update neck entities position on position changed.
enemy:register_event("on_position_changed", function(enemy, x , y, layer)

  -- Workaround: This event seems to be called before on_created(), ensure it doesn't.
  if not initial_position.x then
    return
  end

  -- Place neck entities.
  -- The Y position is placed every 20px of the base-to-head line, and the X one somewhere on the power 2 curve depending on the y position.
  local distance_x = x - initial_position.x
  local distance_y = y - initial_position.y
  if distance_y ~= 0 then
    local step_y = math.sin(enemy:get_angle(initial_position.x, initial_position.y)) * 20
    for index, neck in ipairs(neck_entities) do
      local neck_y = math.max(initial_position.y, y - index * step_y)
      local neck_x = initial_position.x + math.pow(1.0 / distance_y * (neck_y - initial_position.y), 2) * distance_x
      neck:set_position(neck_x , neck_y)
    end
  end
end)

-- Remove neck entities on dead.
enemy:register_event("on_dead", function(enemy)

  for _, neck in ipairs(neck_entities) do
    neck:remove()
  end
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(16)
  enemy:set_damage(2)
  enemy:set_size(32, 64)
  enemy:set_origin(16, 30)
  initial_position.x, initial_position.y, initial_position.layer = enemy:get_position()

  -- Create neck parts
  for i = 1, neck_entities_number, 1 do
    neck_entities[i] = create_neck_sub_entity("neck")
  end
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = "protected",
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
  	thrust = "protected"
  })

  -- States.
  enemy:set_can_attack(true)
  enemy:set_traversable(true)
  if not is_awake then
    start_sleeping()
  else
    start_swinging(1)
  end
end)

----------------------------------
--
-- Gohma.
--
-- Moves horizontally and change direction on wall reached, speeding up if the hero is vertically aligned.
-- Randomly throw a fireball or chase the hero if the hero is vertically near enough.
-- Open his eye and become vulnerable just before throwing the fireball.
-- Blue skin applied if another gohma enemy already exists on the map when created.
--
-- Methods : enemy:start_walking([speed, [direction2]])
--           enemy:start_running()
--           enemy:start_charging()
--           enemy:start_firing()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local body_sprite, eye_sprite
local quarter = math.pi * 0.5
local is_attacking

-- Configuration variables
local walking_speed = 88
local running_speed = 176
local shaking_duration = 1000
local running_minimum_duration = 2000
local running_maximum_duration = 4000
local between_attack_minimum_duration = 1000
local between_attack_maximum_duration = 4000
local before_seeking_duration = 500
local before_firing_duration = 400
local after_firing_duration = 600
local firering_probability = 0.5
local run_triggering_vertical_distance = 8
local attacks_triggering_vertical_distance = 56

-- Return true if the entity is vertically aligned with the enemy.
local function is_vertically_aligned(entity, distance)

  local _, y, _ = enemy:get_position()
  local _, entity_y, _ = entity:get_position()
  return entity_y > y - distance and entity_y < y + distance
end

-- Start the appropriate movement and attack sequence.
local function start_pattern_sequence()

  enemy:start_walking()
  sol.timer.start(enemy, math.random(between_attack_minimum_duration, between_attack_maximum_duration), function()
    if not is_vertically_aligned(hero, attacks_triggering_vertical_distance) then
      return true
    end
    if math.random() < firering_probability then
      enemy:start_firing()
    else
      enemy:start_charging()
    end
  end)
end

-- Check if the custom death as to be started before triggering the built-in hurt behavior.
local function hurt(damage)

  -- Custom die if no more life.
  if enemy:get_life() - damage < 1 then

    -- Wait a few time, start 2 sets of explosions close from the enemy, wait a few time again and finally make the final explosion and enemy die.
    enemy:start_death(function()
      body_sprite:set_animation("hurt")
      eye_sprite:set_opacity(0)
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

  -- Else hurt normally.
  enemy:hurt(damage)
end

-- Make the enemy walk to the given direction at the given speed.
function enemy:start_walking(speed, direction2)

  speed = speed or walking_speed
  direction2 = direction2 or math.floor(body_sprite:get_direction() / 2)

  -- Start walking and change direction on stopped.
  local movement = enemy:start_straight_walking(direction2 * math.pi, speed, nil, function()
    enemy:start_walking(speed, (direction2 + 1) % 2)
  end)
  movement:set_smooth(false)

  -- Shake and move faster for a while if the hero is vertically aligned.
  function movement:on_position_changed()
    if not is_attacking and is_vertically_aligned(hero, run_triggering_vertical_distance) then
      enemy:start_running()
    end
  end
end

-- Make the enemy shake then speed up its walk for some time.
function enemy:start_running()

  is_attacking = true
  enemy:stop_movement()
  sol.timer.stop_all(enemy)
  body_sprite:set_animation("shaking")
  sol.timer.start(enemy, shaking_duration, function()
    enemy:start_walking(running_speed)
    sol.timer.start(enemy, math.random(running_minimum_duration, running_maximum_duration), function()
      enemy:restart()
    end)
    body_sprite:set_animation("chasing")
  end)
end

-- Make the enemy shake then charge the hero.
function enemy:start_charging()

  is_attacking = true
  enemy:stop_movement()
  sol.timer.stop_all(enemy)
  body_sprite:set_animation("shaking")
  sol.timer.start(enemy, shaking_duration, function()
    local start_x, start_y, _ = enemy:get_position()
    local target_angle = enemy:get_angle(hero)
    local movement = enemy:start_straight_walking(target_angle, running_speed, nil, function()
      local back_movement = sol.movement.create("target")
      back_movement:set_speed(running_speed)
      back_movement:set_target(start_x, start_y)
      back_movement:start(enemy)

      function back_movement:on_finished()
        enemy:restart()
      end
    end)
    movement:set_smooth(false)
    body_sprite:set_animation("chasing")
  end)
end

-- Make the enemy open his eye and throw a fireball to the hero.
function enemy:start_firing()
  
  is_attacking = true
  enemy:stop_movement()
  sol.timer.stop_all(enemy)
  body_sprite:set_animation("immobilized")
  eye_sprite:set_opacity(255)
  sol.timer.start(enemy, before_seeking_duration, function()
    eye_sprite:set_animation("opening", function()

      enemy:set_hero_weapons_reactions({
        arrow = function() hurt(2) end,
        hookshot = function() hurt(1) end
      })
      enemy:set_invincible_sprite(body_sprite)

      -- Wait a few time, then fire and close the eye.
      body_sprite:set_animation("eye_open")
      eye_sprite:set_animation("opened")
      sol.timer.start(enemy, before_firing_duration, function()
        enemy:create_enemy({
          name = (enemy:get_name() or enemy:get_breed()) .. "_fireball",
          breed = "projectiles/fireball"
        })
        sol.timer.start(enemy, after_firing_duration, function()
          eye_sprite:set_animation("closing", function()
            enemy:restart()
          end)
        end)
      end)
    end)
  end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(6)
  enemy:set_size(40, 16)
  enemy:set_origin(20, 13)

  -- Create the first gohma with the classic red skin and others with the blue one.
  local body_sprite_name = "enemies/" .. enemy:get_breed()
  local eye_sprite_name = "enemies/" .. enemy:get_breed() .. "/eye"
  for map_enemy in map:get_entities_by_type("enemy") do
    if map_enemy ~= enemy and map_enemy:get_breed() == enemy:get_breed() then
      body_sprite_name = "enemies/" .. enemy:get_breed() .. "/blue"
      eye_sprite_name = "enemies/" .. enemy:get_breed() .. "/blue_eye"
      break
    end
  end
  body_sprite = enemy:create_sprite(body_sprite_name)
  eye_sprite = enemy:create_sprite(eye_sprite_name)
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
  	shield = "protected",
  	thrust = "protected"
  })

  -- States.
  is_attacking = false
  eye_sprite:set_opacity(0)
  eye_sprite:set_animation("closed") -- Set an existing animation to avoid error on non-existing walking one.
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_can_attack(true)
  enemy:set_damage(4)
  start_pattern_sequence()
end)

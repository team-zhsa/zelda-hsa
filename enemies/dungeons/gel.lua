-- Lua script of enemy gel.
-- This script is executed every time an enemy with this model is created.

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local sprite = enemy:create_sprite("enemies/dungeons/gel")
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local is_attacking, is_exhausted, is_adhesive
local hero_speed = hero:get_walking_speed()

-- Configuration variables
local walking_speed = 2
local jumping_speed = 64
local jumping_height = 12
local jumping_duration = 600
local attack_triggering_distance = 64
local shaking_duration = 1000
local exhausted_minimum_duration = 2000
local exhausted_maximum_duration = 4000
local slow_speed = 22
local stuck_minimum_duration = 2000
local stuck_maximum_duration = 2500

-- Return true if no enemy is currenly leashed by hero on the map.
local function is_hero_free()

  for enemy in map:get_entities_by_type("enemy") do
    if enemy.is_leashed_by and enemy:is_leashed_by(hero) then
      return false
    end
  end
  return true
end

-- Start moving to the hero, and jump when he is close enough.
function enemy:start_walking()
  
  local movement = enemy:start_target_walking(hero, walking_speed)
  function movement:on_position_changed()
    if not is_attacking and not is_exhausted and enemy:is_near(hero, attack_triggering_distance) then
      is_attacking = true
      movement:stop()
      
      -- Shake for a short duration then start attacking.
      sprite:set_animation("shaking")
      sol.timer.start(enemy, shaking_duration, function()
         enemy:start_jump_attack(true)
      end)
    end
  end
end

-- Start jumping to or away to the hero.
function enemy:start_jump_attack(offensive)

  local hero_x, hero_y, _ = hero:get_position()
  local enemy_x, enemy_y, _ = enemy:get_position()
  local angle = math.atan2(hero_y - enemy_y, enemy_x - hero_x) + (offensive and math.pi or 0)
  enemy:start_jumping(jumping_duration, jumping_height, angle, jumping_speed, function()
    enemy:restart()
  end)
  sprite:set_animation("jumping")
end

-- Let go the hero.
function enemy:free_hero()

  enemy:stop_leashed_by(hero)

  -- Restore the hero speed and weapons only if there are no more leashed gel.
  if is_hero_free() then
    hero:set_walking_speed(hero_speed)
  end
end

-- Make the hero slow down and unable to use weapons. 
function enemy:slow_hero_down()

  -- Stop potential current jump and slow the hero down.
  enemy:stop_movement()
  sol.timer.stop_all(enemy)
  sprite:set_xy(0, 0)
  hero:set_walking_speed(slow_speed)
  
  -- Make the enemy follow the hero.
  enemy:start_leashed_by(hero, 6)
  sprite:set_animation("shaking")

  -- TODO Make the hero unable to use weapon while slowed down.
  --game:set_ability("sword", 0)
  --game:set_item_assigned(1, nil)
  --game:set_item_assigned(2, nil)

  -- Jump away after some time.
  sol.timer.start(enemy, math.random(stuck_minimum_duration, stuck_maximum_duration), function()
    enemy:free_hero()
    enemy:start_jump_attack(false)
  end)
end

-- Passive behaviors needing constant checking.
enemy:register_event("on_update", function(enemy)

  if enemy:is_immobilized() then
    return
  end

  -- If the hero touches the center of the enemy, slow him down.
  if is_adhesive and enemy:get_life() > 0 and enemy:overlaps(hero, "origin") then
    is_adhesive = false
    enemy:slow_hero_down()
  end
end)

-- Free the hero on dying
enemy:register_event("on_dying", function(enemy)
  enemy:free_hero()
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_size(12, 12)
  enemy:set_origin(6, 9)
  enemy:start_shadow(nil, "small")
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  -- Behavior for each items.
  enemy:set_hero_weapons_reactions(1, {jump_on = "ignored"})

  -- States.
  is_attacking = false
  is_exhausted = true
  is_adhesive = true
  sprite:set_xy(0, 0)
  sol.timer.start(enemy, math.random(exhausted_minimum_duration, exhausted_maximum_duration), function()
    is_exhausted = false
  end)
  enemy:set_obstacle_behavior("normal")
  enemy:set_can_attack(false)
  enemy:set_damage(0)
  enemy:start_walking()
end)

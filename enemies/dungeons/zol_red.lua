-- Lua script of enemy zol_red.
-- This script is executed every time an enemy with this model is created.

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local map = enemy:get_map()
local hero = map:get_hero()
local is_attacking, is_exhausted

-- Configuration variables
local walking_speed = 4
local jumping_speed = 64
local jumping_height = 12
local jumping_duration = 600
local attack_triggering_distance = 64
local shaking_duration = 1000
local exhausted_minimum_duration = 2000
local exhausted_maximum_duration = 4000
local before_split_duration = 300
local gel_spawn_jumping_height = 8
local gel_spawn_jumping_duration = 400

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
         enemy:start_jump_attack()
      end)
    end
  end
end

-- Start jumping to the hero.
function enemy:start_jump_attack()

  local hero_x, hero_y, _ = hero:get_position()
  local enemy_x, enemy_y, _ = enemy:get_position()
  local angle = math.atan2(hero_y - enemy_y, enemy_x - hero_x) + math.pi
  enemy:start_jumping(jumping_duration, jumping_height, angle, jumping_speed, function()
    enemy:restart()
  end)
  sprite:set_animation("jumping")
end

-- Remove the zol and split it into two gels.
function enemy:split()

  enemy:set_invincible()

  local x, y, layer = enemy:get_position()
  local function create_gel(x_offset)
    local gel = map:create_enemy({
      name = (enemy:get_name() or enemy:get_breed()) .. "_gel",
      breed = "gel",
      x = x + x_offset,
      y = y,
      layer = layer,
      direction = enemy:get_direction4_to(hero)
    })

    -- Make gel jump.
    gel:stop_movement()
    gel:start_jumping(gel_spawn_jumping_duration, gel_spawn_jumping_height, nil, nil, function()
      gel:restart()
    end)
    gel:get_sprite():set_animation("jumping")
  end

  -- Start hurt behavior for some time then split into gels.
  enemy:hurt(0)
  sol.timer.start(map, before_split_duration, function()
    create_gel(-5)
    create_gel(5)
    enemy:silent_kill()
  end)
  
end

-- Split the zol if hurt and not directly dead.
enemy:register_event("on_hurt", function(enemy)

  if enemy:get_life() > 0 then
    enemy:split()
  end
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(2)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  shadow = enemy:start_shadow()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  -- Behavior for each items.
	enemy:set_attack_consequence("sword", 1)
	enemy:set_attack_consequence("explosion", 1)

  -- States.
  is_attacking = false
  is_exhausted = true
  sprite:set_xy(0, 0)
  sol.timer.start(enemy, math.random(exhausted_minimum_duration, exhausted_maximum_duration), function()
    is_exhausted = false
  end)
  enemy:set_obstacle_behavior("normal")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_damage(2)
  enemy:start_walking()
end)
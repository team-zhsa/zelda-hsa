-- Lua script of enemy boss/tentacle_big.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local movement
local phase
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
local going_speed = 128
require("enemies/lib/common_actions").learn(enemy)

-- Event called when the enemy is initialised.
function enemy:on_created()

  -- initialise the properties of your enemy here,
  -- like the sprite, the life and the damage.
	enemy:set_size(32, 32)
	enemy:set_origin(16, 29)
  enemy:set_life(35)
  enemy:set_damage(3)
	enemy:create_sprite("enemies/boss/tentacle_boss")
	enemy:set_hurt_style("boss")
	phase = 1
end

local function shoot_tentacle()

  local sprite = enemy:get_sprite()
  sprite:set_animation("shooting")
	sol.audio.play_sound("boss_charge")
  sol.timer.start(enemy, 300 , function()
    sprite:set_animation("walking_angry")

    enemy:create_enemy({
      breed = "boss/fireball_red_big",
      name = projectile_prefix,
    })
    sol.audio.play_sound("boss_fireball")
  end)

  return true  -- Repeat the timer until hurt.
end

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
        enemy:start_brief_effect("entities/effects/impact_projectile", "default", -12, 0)
        enemy:start_brief_effect("entities/effects/impact_projectile", "default", 12, 0)
        sol.timer.start(enemy, stunned_duration, function()
          enemy:restart()
        end)
      end)
    end)
  end)
end

function enemy:on_obstacle_reached()
	if phase == 3 then
  local dxy = {
    { x =  1, y =  0},
    { x =  1, y = -1},
    { x =  0, y = -1},
    { x = -1, y = -1},
    { x = -1, y =  0},
    { x = -1, y =  1},
    { x =  0, y =  1},
    { x =  1, y =  1}
  }

  -- The current direction is last_direction8:
  -- try the three other diagonal directions.
  local try1 = (last_direction8 + 2) % 8
  local try2 = (last_direction8 + 6) % 8
  local try3 = (last_direction8 + 4) % 8

  if not self:test_obstacles(dxy[try1 + 1].x, dxy[try1 + 1].y) then
    self:go(try1)
  elseif not self:test_obstacles(dxy[try2 + 1].x, dxy[try2 + 1].y) then
    self:go(try2)
  else
    self:go(try3)
  end
	end
end

-- Makes the Bubble go towards a diagonal direction (1, 3, 5 or 7).
function enemy:go(direction8)

  local m = sol.movement.create("straight")
  m:set_speed(going_speed)
  m:set_smooth(false)
  m:set_angle(direction8 * math.pi / 4)
  m:start(self)
  last_direction8 = direction8
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
	if enemy:get_life() <= 30 and enemy:get_life() > 20 then
		phase = 2
	end
	if phase == 1 then
  	movement = sol.movement.create("target")
  	movement:set_target(hero)
  	movement:set_speed(16)
  	movement:start(enemy)
		enemy:set_hero_weapons_reactions({
  		arrow = 1,
  		boomerang = 1,
  		explosion = 2,
  		sword = 1,
  		thrown_item = 1,
  		fire = 1,
  		jump_on = "ignored",
  		hammer = 5,
  		hookshot = 1,
  		magic_powder = 1,
  		shield = "protected",
  		thrust = 1
  	})
	elseif phase == 2 then
		local sprite = enemy:get_sprite()
  	sprite:set_animation("walking_angry")
  	movement = sol.movement.create("target")
  	movement:set_target(hero)
  	movement:set_speed(48)
  	movement:start(enemy)
		enemy:set_hero_weapons_reactions({
  		arrow = 1,
  		boomerang = "immobilized",
  		explosion = 2,
  		sword = "protected",
  		thrown_item = 1,
  		fire = 2,
  		jump_on = "ignored",
  		hammer = 5,
  		hookshot = 1,
  		magic_powder = 1,
  		shield = "protected",
  		thrust = "immobilized"
  	})
		sol.timer.start(enemy, 2000, function()
			start_jumping()
		end)
	end
end

function enemy:on_immobilized()
	enemy:set_hero_weapons_reactions({
  		arrow = 1,
  		boomerang = 2,
  		explosion = 2,
  		sword = 2,
  		thrown_item = 1,
  		fire = 2,
  		jump_on = "ignored",
  		hammer = 5,
  		hookshot = 1,
  		magic_powder = 1,
  		shield = "protected",
  		thrust = "immobilized"
  	})
end
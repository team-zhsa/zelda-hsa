----------------------------------
--
-- Helmasaur.
--
-- Moves randomly over horizontal and vertical axis, and is invulnerable to front attacks.
-- Can be defeated by attacking him in the back, or take off his mask with the hookshot to set him weak from everywhere.
--
-- Methods : enemy:set_weak()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)
require("enemies/lib/weapons").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5
local is_mask_hooked = false
local is_weak = false

-- Configuration variables
local walking_angles = {0, quarter, 2.0 * quarter, 3.0 * quarter}
local walking_speed = 32
local walking_minimum_distance = 16
local walking_maximum_distance = 32
local weak_walking_speed = 48
local weak_walking_minimum_distance = 16
local weak_walking_maximum_distance = 96
local front_angle = 7.0 * math.pi / 6.0

local speed = walking_speed
local minimum_distance = walking_minimum_distance
local maximum_distance = walking_maximum_distance

-- Hurt if the hero is in the back of the enemy.
local function on_sword_attack_received()

  enemy:set_invincible() -- Make sure to only trigger this event once by attack.

  if is_weak or not enemy:is_entity_in_front(hero, front_angle) then
    enemy:hurt(1)
  else
    enemy:start_shock(hero, 100, 150, sprite, nil, function()
      enemy:restart()
    end)
  end
end

-- Hurt if the hero is in the back of the enemy, else hurt the hero.
local function on_thrust_attack_received()

  if is_weak or not enemy:is_entity_in_front(hero, front_angle) then
    enemy:set_invincible() -- Make sure to only trigger this event once by attack.
    enemy:hurt(1)
  else
    enemy:start_pushing_back(hero, 100, 150, sprite, nil)
    hero:start_hurt(enemy:get_damage())
  end
end

-- Start the enemy movement.
local function start_walking()

  enemy:start_straight_walking(walking_angles[math.random(4)], speed, math.random(minimum_distance, maximum_distance), function()
    start_walking()
  end)
end

-- Make the enemy faster and maskless.
function enemy:set_weak()

  is_weak = true

  speed = weak_walking_speed
  minimum_distance = weak_walking_minimum_distance
  maximum_distance = weak_walking_maximum_distance
  enemy:start_brief_effect("entities/effects/sparkle_small", "default", 0, 0)
  enemy:restart()
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(5)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = 2,
  	boomerang = 2,
  	explosion = 2,
  	sword = on_sword_attack_received,
  	thrown_item = 2,
  	fire = 2,
  	jump_on = "ignored",
  	hammer = 5,
  	hookshot = on_hookshot_attack_received,
  	magic_powder = 2,
  	shield = "protected",
  	thrust = on_thrust_attack_received
  })

  -- States.
  enemy:set_can_attack(true)
  enemy:set_damage(4)
  start_walking()
end)

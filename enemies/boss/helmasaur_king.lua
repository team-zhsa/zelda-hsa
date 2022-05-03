----------------------------------
--
-- Helmasaur King.
--
-- Moves randomly over horizontal and vertical axis, and is invulnerable to front attacks.
-- Can be defeated by taking off his mask with the hookshot to set him weak.
-- Phases : I) Masked, II) Masked, III) Masked, IV) Unmasked
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
local is_weak = false
local phase = 1
local child_prefix = enemy:get_name() .. "_child"

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


-- Hurt if unmasked.
local function on_sword_attack_received()

  enemy:set_invincible() -- Make sure to only trigger this event once by attack.

  if is_weak then --or not enemy:is_entity_in_front(hero, front_angle) then
    enemy:hurt(1)
  else
    enemy:start_shock(hero, 100, 150, sprite, nil, function()
      enemy:restart()
    end)
  end
end

-- Hurt if unmasked, else hurt the hero.
local function on_thrust_attack_received()

  if is_weak then
    enemy:set_invincible() -- Make sure to only trigger this event once by attack.
    enemy:hurt(1)
  else
    enemy:start_pushing_back(hero, 100, 150, sprite, nil)
    hero:start_hurt(enemy:get_damage())
  end
end

-- Hurt if enemy and hero have same direction, else grab the mask and make enemy weak.
local function on_explosion_attack_received()

  enemy:set_invincible()

  if is_weak then
    enemy:hurt(1)
  elseif phase == 1 then
    phase = 2
    enemy:hurt(0)
  elseif phase == 2 then
    phase = 3
    enemy:hurt(0)
  elseif phase == 3 then
    enemy:set_weak()
    enemy:hurt(0)
  end
end

-- Hurt if enemy and hero have same direction, else grab the mask and make enemy weak.
local function on_hammer_attack_received()

  enemy:set_invincible()

  if is_weak then
    enemy:hurt(2)
  elseif phase == 1 then
    phase = 2
    enemy:hurt(0)
  elseif phase == 2 then
    phase = 3
    enemy:hurt(0)
  elseif phase == 3 then
    enemy:set_weak()
    enemy:hurt(0)
  end
end

-- Start the enemy movement.
local function start_walking()
  sprite:set_animation("walking_phase_" .. phase)
  enemy:start_straight_walking(walking_angles[math.random(4)], speed, math.random(minimum_distance, maximum_distance), function()
    start_walking()
  end)
end

-- Make the enemy faster and maskless. (Phase IV)
function enemy:set_weak()

  is_weak = true
    phase = 4

  speed = weak_walking_speed
  minimum_distance = weak_walking_minimum_distance
  maximum_distance = weak_walking_maximum_distance

  sprite:set_animation("walking_phase_4")
  enemy:start_brief_effect("entities/effects/sparkle_small", "default", 0, 0)
  enemy:restart()
end

-- Spawn a hardhat beetle.
function enemy:spawn_hardhat()

  local sprite = enemy:get_sprite()
	--sol.audio.play_sound("boss_charge")
 -- sol.timer.start(enemy, 100, function()
    sprite:set_animation("walking_phase_4")
    local x, y, layer = enemy:get_position()
    enemy:get_map():create_enemy({
      breed = "dungeon/goriya_green",
      name = child_prefix,
      x = x,
      y = y,
      layer = layer,
      direction = 3
    })
    sol.audio.play_sound("boss_fireball")
 -- end)

  --return true  -- Repeat the timer until hurt.
end


-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(20)
  enemy:set_size(80, 112)
  enemy:set_origin(40, 101)
  enemy:set_hurt_style("boss")

end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = 2,
  	boomerang = "protected",
  	explosion = on_explosion_attack_received,
  	sword = on_sword_attack_received,
  	thrown_item = 2,
  	fire = 2,
  	jump_on = "ignored",
  	hammer = on_hammer_attack_received,
  	hookshot = "ignored",
  	magic_powder = "ignored",
  	shield = "protected",
  	thrust = on_thrust_attack_received
  })

  -- States.
  enemy:set_can_attack(true)
  enemy:set_damage(2)
  start_walking()
  
  if phase == 4 then
    sol.timer.start(enemy, math.random(4, 8) * 200, function()
      enemy:spawn_hardhat()
    end)
  end
  
end)

enemy:register_event("on_dying", function()
  local map = enemy:get_map()
  map:remove_entities(child_prefix)
end)





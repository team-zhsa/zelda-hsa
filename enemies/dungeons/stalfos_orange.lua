----------------------------------
--
-- Stalfos Red.
--
-- Moves randomly over horizontal and vertical axis.
-- Pounce away when the hero attacks too closely, then throw a projectile.
-- May be set_unarmed() or set_exhausted() manually from outside this script.
--
-- Methods : enemy:set_unarmed([unarmed])
--           enemy:set_exhausted([exhausted])
--           enemy:start_walking()
--           enemy:start_attacking()
--           enemy:start_throwing_bone()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5

-- Configuration variables
local is_unarmed = true--enemy:get_property("is_unarmed") == "true"
local walking_angles = {0, quarter, 2.0 * quarter, 3.0 * quarter}
local walking_speed = 32
local walking_minimum_distance = 16
local walking_maximum_distance = 96
local waiting_duration = 1600
local attack_triggering_distance = 64
local jumping_speed = 128
local jumping_height = 16
local jumping_duration = 600
local throwing_bone_delay = 600

-- Make this enemy throw bones or not.
function enemy:set_unarmed(unarmed)
  is_unarmed = unarmed or true
end

-- Make the enemy able to attack or not.
function enemy:set_exhausted(exhausted)
  enemy.is_exhausted = exhausted or true
end

-- Start the enemy movement.
function enemy:start_walking(direction)
  direction = direction or math.random(4)
  enemy:start_straight_walking(walking_angles[direction], walking_speed, math.random(walking_minimum_distance, walking_maximum_distance), function()
    local next_direction = math.random(4)
    local waiting_animation = "looking_around"
    sprite:set_animation(waiting_animation)
    --print(waiting_animation)
    sol.timer.start(enemy, waiting_duration, function()
      enemy:start_walking(next_direction)
    end)
  end)
end

-- Event triggered when the enemy is close enough to the hero.
function enemy:start_attacking()

  -- Start jumping away from the hero.
  local hero_x, hero_y, _ = hero:get_position()
  local enemy_x, enemy_y, _ = enemy:get_position()
  local angle = math.atan2(hero_y - enemy_y, enemy_x - hero_x)
  enemy:start_jumping(jumping_duration, jumping_height, angle, jumping_speed, function()
    enemy:restart()
    if enemy:exists() then -- Throw a bone if the enemy still exists after the restart.
    --  enemy:start_throwing_bone()
    end
  end)
  sprite:set_animation("jumping")
  enemy.is_exhausted = true
end

-- Start walking again when the attack finished.
function enemy:start_throwing_bone()

  -- Throw a bone club at the hero after a delay.
  if not is_unarmed then
    sol.timer.start(enemy, throwing_bone_delay, function()
      
      local x, y, layer = enemy:get_position()
      map:create_enemy({
        name = (enemy:get_name() or enemy:get_breed()) .. "_bone",
        breed = "projectiles/bone",
        x = x,
        y = y,
        layer = layer,
        direction = enemy:get_direction4_to(hero)
      })
    end)
  end
end

-- Start attacking when the hero is near enough and an attack or item command is pressed, even if not assigned to an item.
map:register_event("on_command_pressed", function(map, command)

  if not enemy:exists() or not enemy:is_enabled() then
    return
  end

  if not enemy.is_exhausted then
    if enemy:is_near(hero, attack_triggering_distance) and (command == "attack" or command == "item_1" or command == "item_2") then
      enemy:start_attacking()
    end
  end
end)

-- Set exhausted on hurt.
enemy:register_event("on_hurt", function(enemy)
  enemy:set_exhausted(true)
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(4)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:start_shadow()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = 4,
  	boomerang = "immobilized",
  	explosion = 2,
  	sword = 1,
  	thrown_item = 2,
  	fire = "immobilized",
  	jump_on = "ignored",
  	hammer = 4,
  	hookshot = "immobilized",
  	magic_powder = "ignored",
  	shield = "protected",
  	thrust = 4
  })

  -- States.
  sprite:set_xy(0, 0)
  enemy:set_obstacle_behavior("normal")
  enemy.is_exhausted = false
  enemy:set_can_attack(true)
  enemy:set_damage(2)
  enemy:start_walking()
end)

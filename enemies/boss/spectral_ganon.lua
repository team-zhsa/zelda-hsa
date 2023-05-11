----------------------------------
--
-- Shadow of Ganon.
--
-- Start by taking a double-axe in his hand, then invoke some bats that charge the hero and finally throw the axe to the hero, then move to another position.
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local camera = map:get_camera()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local hurt_shader = sol.shader.create("hurt")
local quarter = math.pi * 0.5
local circle = math.pi * 2.0
local center_x, center_y
local axe
local is_hurt = false
local is_pushing_back = false

-- Configuration variables.
local before_arming_duration = 800
local after_arming_duration = 800
local bats_count = 1
local bats_distance = 40
local between_bats_duration = 5000 --500
local aiming_duration = 500
local moving_speed = 120
local moving_distance_from_center = 48
local hurt_duration = 600
local dying_duration = 2000

-- Check if the custom death as to be started before triggering the built-in hurt behavior.
local function hurt(damage)

  if is_hurt then
    return
  end
  is_hurt = true
  enemy:set_hero_weapons_reactions({sword = "protected", thrust = "protected"})

  --Make the enemy manually hurt to not restart it automatically.
  enemy:set_life(enemy:get_life() - damage)
  local animation = sprite:get_animation()
  sprite:set_animation("hurt")
  sol.timer.start(enemy, hurt_duration, function()
    is_hurt = false
    sprite:set_animation(animation)
    enemy:set_vulnerable()
  end)

  if enemy.on_hurt then
    enemy:on_hurt()
  end
end

-- Only hurt a sword attack received if the attack is a spin one.
local function on_sword_attack_received()

  --if hero:get_sprite():get_animation() == "spin_attack" or hero:get_sprite():get_animation() == "super_spin_attack" then
    hurt(1)
  --end
  if not is_pushing_back then
    is_pushing_back = true
    enemy:start_pushing_back(hero, 200, 100, sprite, nil, function()
      is_pushing_back = false
    end)
  end
end

-- Create a sub enemy and echo some of the main enemy methods.
local function create_sub_enemy(name, breed, x, y, direction)

  local sub_enemy = enemy:create_enemy({
      name = (enemy:get_name() or enemy:get_breed()) .. "_" .. name,
      breed = breed,
      x = x,
      y = y,
      layer = map:get_max_layer(),
      direction = direction
    })

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

  return sub_enemy
end

-- Start throwing the axe to the hero.
local function start_throwing()

  local mirror_ratio = (sprite:get_direction() == 0) and 1 or -1
  sprite:set_animation("aiming")
  axe:start_aiming(19 * mirror_ratio, 15)
  sol.timer.start(enemy, aiming_duration, function()
    sprite:set_animation("throwing")
    axe:start_throwed(enemy)
  end)
end

-- Start invoking bats.
local function start_invoking()

  local mirror_ratio = (sprite:get_direction() == 0) and 1 or -1
  sprite:set_animation("invoking")
  axe:start_spinning(19 * mirror_ratio, 15)

  -- Start invoking bats.
  local bat_count = 0
  local angle_gap = circle / bats_count
  sol.timer.start(enemy, between_bats_duration, function()
    bat_count = bat_count + 1
    local angle = angle_gap * -bat_count
    create_sub_enemy("bat", "projectiles/bat", math.cos(angle) * bats_distance * mirror_ratio, -math.sin(angle) * bats_distance - 32, 2)

    -- Start throwing the axe after the last invoke.
    if bat_count >= bats_count then
      start_throwing()
      return
    end

    return true
  end)
end

-- Start moving to another place.
local function start_moving()

  local random_angle = math.random() * circle -- Random angle between 0 and pi
  local x, y = center_x + math.cos(random_angle) * moving_distance_from_center, center_y - math.sin(random_angle) * moving_distance_from_center
  enemy:start_straight_walking(enemy:get_angle(x, y), moving_speed, enemy:get_distance(x, y), function()
    local direction = x < center_x and 0 or 2
    sprite:set_direction(direction)
    axe:get_sprite():set_direction(direction)
  end)
  sprite:set_animation("stopped")
end

-- Start taking the axe in hand.
local function start_taking_axe()

  sprite:set_animation("waiting")
  sol.timer.start(enemy, before_arming_duration, function()
    sprite:set_animation("invoking")
    sprite:set_paused()

    -- Create the axe.
    axe = create_sub_enemy("axe", "projectiles/axe", 0, 0, sprite:get_direction())
    local axe_sprite = axe:get_sprite()

    -- Start invoking bats when the axe is holded or catched.
    local function holded()
      sprite:set_animation("stopped")
      axe:start_holded(-4, 21)
      sol.timer.start(enemy, after_arming_duration, function()
        start_invoking()
      end)
    end

    function axe:on_took()
      holded()
    end
    function axe:on_catched()
      holded()
    end
    axe:start_taking(-4, 21)

    -- Start moving when axe go back.
    function axe:on_go_back()
      start_moving()
    end
  end)
end

-- Set enemy vulnerable.
enemy:register_event("set_vulnerable", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = "protected",
  	boomerang = "protected",
  	explosion = "protected",
  	sword = on_sword_attack_received,
  	thrown_item = "protected",
  	fire = "protected",
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = "protected",
  	magic_powder = "ignored",
  	shield = "protected",
  	thrust = function() hurt(2) end
  })
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(15)
  enemy:set_size(48, 48)
  enemy:set_origin(32, 42)
  enemy:set_hurt_style("boss")

  local camera_x, camera_y, camera_width, camera_height = camera:get_bounding_box()
  center_x, center_y = camera_x + camera_width * 0.5, camera_y + camera_height * 0.5
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_vulnerable()

  -- States.
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_can_attack(true)
  enemy:set_damage(4)
  start_taking_axe()
end)

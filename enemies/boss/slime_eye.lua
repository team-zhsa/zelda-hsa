----------------------------------
--
-- Slime Eye.
--
-- Start by falling from the ceiling, then slightly move until the hero split it into two enemies with sword or thrust attack.
-- Once splitted, randomly jump accross the room and die when the two splitted parts are defeated.
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)
local map_tools = require("scripts/maps/map_tools")

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local camera = map:get_camera()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local circle = math.pi * 2.0
local quarter = math.pi * 0.5
local is_upstairs = true
local is_hurt = false
local is_pushing_back = false
local splitted_eye_1, splitted_eye_2
local deformity_timer

-- Configuration variables
local falling_duration = 750
local stunned_duration = 1000
local walking_speed = 4
local walking_minimum_distance = 4
local walking_maximum_distance = 12
local walking_maximum_distance_from_center = 16
local waiting_duration = 1000
local weakness_ray = 8
local hurt_duration = 600
local deformity_duration = 1250

-- Make the enemy fall from the ceiling.
local function start_falling(on_finished_callback)

  local _, y, layer = enemy:get_position()
  local _, camera_y = camera:get_position()
  sprite:set_xy(0, camera_y - y) -- Move the enemy to the start position right now to ensure it won't be visible before the beginning of the fall.
  sprite:set_animation("falling")
  enemy:set_visible()
  enemy:set_layer(map:get_max_layer())
  enemy:start_throwing(enemy, falling_duration, y - camera_y, nil, nil, nil, function()
    enemy:set_layer(layer)
    
    -- Start a visual effect at the landing impact location, wait a few time and restart.
    map_tools.start_earthquake({count = 12, amplitude = 4, speed = 90})
    enemy:start_brief_effect("entities/effects/impact_projectile", "default", -12, 0)
    enemy:start_brief_effect("entities/effects/impact_projectile", "default", 12, 0)

    -- Stun the hero if not in the air.
    local is_hero_freezed = false
    if not hero:is_jumping() then
      is_hero_freezed = true
      hero:freeze()
      hero:get_sprite():set_animation("scared")
    end

    -- Wait for some time then unfreeze the hero if needed.
    sol.timer.start(hero, stunned_duration, function()
      if is_hero_freezed then
        hero:unfreeze()
      end
    end)

    on_finished_callback()
  end)
end

-- Make the enemy walk randomly, or walk to the center of the room if it is far enough.
local function start_walking()

  local camera_x, camera_y, camera_width, camera_height = camera:get_bounding_box()
  local center_x, center_y = camera_x + camera_width / 2.0, camera_y + camera_height / 2.0
  local angle = enemy:get_distance(center_x, center_y) < walking_maximum_distance_from_center and math.random() * circle or enemy:get_angle(center_x, center_y)
  local distance = math.random(walking_minimum_distance, walking_maximum_distance)

  local movement = enemy:start_straight_walking(angle, walking_speed, distance, function()
    sol.timer.start(enemy, waiting_duration, function()
      start_walking()
    end)
  end)
end

-- Create a splitted eye.
local function create_splitted_eye(x_offset)

  local x, y, layer = enemy:get_position()
  local splitted_eye = map:create_enemy({
    name = (enemy:get_name() or enemy:get_breed()) .. "_splitted_eye",
    breed = "boss/projectiles/splitted_eye",
    x = x + x_offset,
    y = y,
    layer = layer,
    direction = 0
  })

  -- Kill the main enemy when both splitted eyes dead.
  splitted_eye:register_event("on_dead", function(splitted_eye)
    if not splitted_eye_1:exists() and not splitted_eye_2:exists() then
      enemy:start_death()
    end
  end)

  return splitted_eye
end

-- Split into two enemies.
local function split()

  enemy:stop_movement()
  sol.timer.stop_all(enemy)

  enemy:set_visible(false) -- Also hide the shadow.
  enemy:set_can_attack(false)
  enemy:set_invincible()

  splitted_eye_1 = create_splitted_eye(-20)
  splitted_eye_2 = create_splitted_eye(20)
end

-- Hurt if the attack is near enough the eye.
local function on_attack_received(attack)

  -- Hurt behavior if near enough the eye.
  local x, y = enemy:get_position()
  local hero_x, hero_y = hero:get_position()
  if not is_hurt and hero_y > y and hero_x > x - weakness_ray and hero_x < x + weakness_ray then
    is_hurt = true
    enemy:set_hero_weapons_reactions({sword = "protected", thrust = "protected"})

    -- Start the correct hurt animation.
    sprite:set_animation("hurt_" .. 6 - enemy:get_life())
    sol.timer.start(enemy, hurt_duration, function()

      -- Actually hurt only if the attack is a thrust one for the last hit before the split.
      if attack == "thrust" or enemy:get_life() > 1 then

        -- Split into two eyes when no more life.
        if enemy:get_life() == 1 then
          split()
          return
        end
        enemy:set_life(enemy:get_life() - 1)
      end
      enemy:restart()

      -- Timer before the deformity start to reduce.
      deformity_timer = sol.timer.start(enemy, deformity_duration, function()
        enemy:set_life(enemy:get_life() + 1)
        sprite:set_animation("walking_" .. 6 - enemy:get_life())
        if enemy:get_life() < 5 then
          deformity_timer = nil
          return true
        end
      end)
    end)

    if deformity_timer then
      deformity_timer:stop()
      deformity_timer = nil
    end
  end

  -- Repulse the hero and make him restart a possible run.
  if not is_pushing_back then
    is_pushing_back = true
    enemy:start_pushing_back(hero, 200, 100, sprite, nil, function()
      is_pushing_back = false
    end)

    -- Restart the run if still running.
    if hero:is_running() then 
      hero:unfreeze() 
      hero:run()
    end
  end
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(5)
  enemy:set_size(64, 24)
  enemy:set_origin(32, 21)
  enemy:start_shadow("entities/shadows/giant_shadow")
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  -- Behavior for each items.
  enemy:set_hero_weapons_reactions({
  	arrow = "protected",
  	boomerang = "protected",
  	explosion = "ignored",
  	sword = function() on_attack_received("sword") end,
  	thrown_item = "protected",
  	fire = "protected",
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = "protected",
  	magic_powder = "ignored",
  	shield = "protected",
  	thrust = function() on_attack_received("thrust") end
  })

  -- States.
  is_hurt = false
  enemy:set_can_attack(true)
  enemy:set_damage(4)
  enemy:set_layer_independent_collisions(true)
  if is_upstairs then
    start_falling(function()
      is_upstairs = false
      sprite:set_animation("walking_1")
      start_walking()
    end)
  else
    sprite:set_animation("walking_" .. 6 - enemy:get_life())
    start_walking()
  end
end)

----------------------------------
--
-- Rolling Bones.
--
-- Start by pushing a spike across the room, then zigzag jump to go back behind and push it again through the other side of the room.
-- Slightly increase the speed each time the enemy is hurt.
--
-- Methods : enemy:start_moving()
--           enemy:start_pushing(angle)
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
local hurt_shader = sol.shader.create("hurt")
local spike
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5
local eighth = math.pi * 0.25
local moving_angle = nil
local is_hurt = false

-- Configuration variables
local waiting_duration = 500
local spike_speed = 150
local spike_slow_speed = 60
local jumping_speed = 120
local jumping_speed_increase_by_hp = 5
local jumping_height = 12
local jumping_duration = 500
local between_jumps_duration = 300
local hurt_duration = 300

-- Return the direction to the further left/right of the camera.
local function get_horizontal_further_direction()

  local x = enemy:get_position()
  local camera_x, _, camera_width = camera:get_bounding_box()
  return x > camera_x + camera_width / 2.0 and 2 or 0
end

-- Return the direction to the further up/down side of the camera.
local function get_vertical_further_direction()

  local _, y = enemy:get_position()
  local _, camera_y, _, camera_height = camera:get_bounding_box()
  return y > camera_y + camera_height / 2.0 and 1 or 3
end

-- Check if the custom death as to be started before triggering the built-in hurt behavior.
local function hurt(damage)

  if is_hurt then
    return
  end
  is_hurt = true

  -- Custom die if no more life.
  if enemy:get_life() - damage < 1 then

    -- Wait a few time, start 2 sets of explosions close from the enemy, wait a few time again and finally make the final explosion and enemy die.
    enemy:start_death(function()
      local _, offset_y = sprite:get_xy()
      sprite:set_animation("hurt")
      sol.timer.start(enemy, 1500, function()
        enemy:start_close_explosions(32, 2500, "entities/explosion_boss", 0, offset_y - 14, function()
          sol.timer.start(enemy, 1000, function()
            enemy:start_brief_effect("entities/explosion_boss", nil, 0, offset_y - 14)
            finish_death()
          end)
        end)
        sol.timer.start(enemy, 200, function()
          enemy:start_close_explosions(32, 2300, "entities/explosion_boss", 0, offset_y - 14)
        end)
      end)
    end)
    return
  end

  -- Else manually hurt, to not interrupt a possible jump.
  enemy:set_life(enemy:get_life() - damage)
  enemy:start_pushed_back(hero, 300, 100, sprite)
  sprite:set_shader(hurt_shader)
  if enemy.on_hurt then
    enemy:on_hurt()
  end

  sol.timer.start(map, hurt_duration, function()
    is_hurt = false
    sprite:set_shader(nil)
  end)
end

-- Start the enemy jumping movement to the opposite side of the room.
function enemy:start_moving()

  local jumping_angle = sol.main.get_angle(0, 0, math.cos(moving_angle), -math.sin(get_vertical_further_direction() * quarter))
  local jumping_final_speed = jumping_speed + jumping_speed_increase_by_hp * (8 - enemy:get_life())
  local movement = enemy:start_jumping(jumping_duration, jumping_height, jumping_angle, jumping_final_speed, function()
    if moving_angle then
      sol.timer.start(enemy, between_jumps_duration, function()
        enemy:start_moving(angle)
      end)
    else
      enemy:restart()
    end
  end)

  -- Stop moving on obstacle reached.
  function movement:on_obstacle_reached()
    movement:stop()
    moving_angle = nil
  end
end

-- Start pushing the spike.
function enemy:start_pushing(angle)

  local spike_sprite = spike:get_sprite()
  sol.timer.start(enemy, waiting_duration, function()
    sprite:set_animation("punching", function()

      -- Start spike movement on punching animation finished.
      moving_angle = angle -- Set the global direction angle here to not start pushing again if hurt.
      sprite:set_animation("waiting")
      spike:start_straight_walking(angle, spike_speed, nil, function()

        -- Start an earthquake when the spike hit the wall and slightly move back.
        map_tools.start_earthquake({count = 12, amplitude = 4, speed = 90})
        spike:start_straight_walking(angle - math.pi, spike_slow_speed, 46, function()
          spike_sprite:set_animation("stopped")
        end)
        spike_sprite:set_frame_delay(100)
      end)
      spike_sprite:set_animation("walking")

      -- Start moving a little after.
      sol.timer.start(enemy, waiting_duration, function()
        enemy:start_moving()
      end)
    end)
  end)
end

-- Kill the spike on dead.
enemy:register_event("on_dead", function(enemy)

  spike:stop_all()
  spike:get_sprite():set_animation("destroyed", function()
    spike:start_death()
  end)
end)

-- Enable the spike on enabled.
enemy:register_event("on_enabled", function(enemy)
  spike:set_enabled()
end)

-- Disable the spike on disabled.
enemy:register_event("on_disabled", function(enemy)
  spike:set_enabled(false)
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(8)
  enemy:set_size(48, 24)
  enemy:set_origin(24, 21)
  enemy:start_shadow("entities/shadows/giant_shadow")

  -- Create the spike.
  spike = enemy:create_enemy({
    name = (enemy:get_name() or enemy:get_breed()) .. "_spike",
    breed = "boss/projectiles/spike",
    direction = 2,
    x = get_horizontal_further_direction() == 2 and -30 or 30
  })
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = function() hurt(4) end,
  	boomerang = function() hurt(8) end,
  	explosion = function() hurt(4) end,
  	sword = function() hurt(1) end,
  	thrown_item = function() hurt(4) end,
  	fire = function() hurt(4) end,
  	jump_on = "ignored",
  	hammer = function() hurt(4) end,
  	hookshot = function() hurt(2) end,
  	magic_powder = function() hurt(4) end,
  	shield = "protected",
  	thrust = function() hurt(2) end
  })

  -- States.
  sprite:set_xy(0, 0)
  enemy:set_obstacle_behavior("normal")
  enemy:set_can_attack(true)
  enemy:set_damage(4)
  if not moving_angle then
    local direction = get_horizontal_further_direction()
    sprite:set_direction(direction)
    enemy:start_pushing(direction * quarter)
  else
    -- Finish to cross the room if hurt during the movement.
    enemy:start_moving()
  end
end)

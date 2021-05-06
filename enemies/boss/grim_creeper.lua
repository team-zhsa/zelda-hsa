----------------------------------
--
-- Grim Creeper.
--
-- Immobile and invincible enemy that invoke bats and throw them to the hero.
-- Beaten when all bats from a round are killed by the hero.
--
-- Events : enemy:on_round_begin(round_number)
--          enemy:on_escaping()
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
local quarter = math.pi * 0.5
local bats = {}
local current_step = 0
local round_count = 0
local is_ready = false

-- Configuration variables.
local incoming_duration = 700
local waiting_time = 1000
local invoking_time = 600
local additional_playing_time = 1000
local throwing_time = 600
local escaping_speed = 280
local bat_positions = { -- [step][bat][start_x, start_y, x, y], all positions relative to the camera position.
  {{212, 0, 90, 112}, {192, 0, 118, 132}, {172, 0, 146, 152}, {148, 0, 174, 152}, {128, 0, 202, 132}, {108, 0, 230, 112}},
  {{212, 0, 112, 200}, {192, 0, 208, 200}, {172, 0, 144, 176}, {148, 400, 176, 224}, {128, 400, 144, 224}, {108, 0, 176, 176}},
  {{212, 0, 56, 152}, {192, 0, 264, 152}, {172, 0, 98, 192}, {148, 0, 222, 192}, {128, 400, 180, 232}, {108, 400, 140, 232}},
  {{212, 0, 90, 112}, {192, 0, 230, 112}, {172, 400, 230, 200}, {148, 400, 90, 200}, {128, 0, 184, 156}, {108, 0, 136, 156}},
  {{212, 0, 90, 112}, {192, 400, 230, 200}, {172, 400, 90, 200}, {148, 0, 230, 112}, {128, 0, 160, 112}, {108, 400, 160, 200}},
  {{212, 0, 118, 150}, {192, 0, 202, 186}, {172, 400, 160, 200}, {148, 0, 160, 136}, {128, 0, 118, 186}, {108, 0, 202, 150}},
  {{212, 0, 112, 120}, {192, 0, 208, 120}, {172, 0, 112, 170}, {148, 0, 208, 170}, {128, 400, 112, 220}, {108, 400, 208, 220}},
  {{212, 0, 90, 152}, {192, 0, 230, 152}, {172, 0, 118, 172}, {148, 0, 146, 152}, {128, 0, 202, 172}, {108, 0, 174, 152}}
} 

-- Create a bat beyond the north side of the camera and make it go to the given position.
local function create_bat(x, y)

  local layer = enemy:get_layer()
  local bat = map:create_enemy({
    name = (enemy:get_name() or enemy:get_breed()) .. "_bat",
    breed = "boss/projectiles/bat",
    direction = 2,
    x = x,
    y = y,
    layer = layer
  })
  table.insert(bats, bat)
  return bat
end

-- Start an incoming animation.
local function start_incoming()

  is_ready = true

  local _, y, layer = enemy:get_position()
  local _, camera_y = map:get_camera():get_position()
  sprite:set_animation("jumping")
  sprite:set_direction(0)

  -- Fall from ceiling, displaying the enemy on the higher layer during the fall.
  sprite:set_xy(0, camera_y - y) -- Move the enemy to the start position right now to ensure it won't be visible before the beginning of the fall.
  enemy:set_layer(map:get_max_layer())
  enemy:start_throwing(enemy, incoming_duration, y - camera_y, nil, nil, nil, function()
    enemy:set_layer(layer)
    enemy:restart()
  end)
end

-- Start an escape animation then make the boss die silently.
local function start_escaping()

  -- Start a jump to the ceiling, then kill the enemy when movement finished.
  local _, y = enemy:get_position()
  local _, camera_y = camera:get_position()
  local height = y - camera_y
  local movement = sol.movement.create("straight")
  movement:set_max_distance(height)
  movement:set_angle(quarter)
  movement:set_speed(escaping_speed)
  movement:set_ignore_obstacles(true)
  movement:start(sprite)
  enemy:set_layer(map:get_max_layer())
  sprite:set_animation("jumping")

  function movement:on_finished()
    enemy:start_death()
  end

  if enemy.on_escaping then
    enemy:on_escaping()
  end
end

-- Wait a few time and throw all bats to the hero.
local function start_throwing()

  sprite:set_animation("attacking")
  for index, bat in ipairs(bats) do
    sol.timer.start(enemy, throwing_time * index, function()
      bat:start_throwed(hero)
    end)
  end
end

-- Make the invoke 6 bats and throw them to the hero.
local function start_invoking(positions)

  local function is_round_finished()
    for _, bat in pairs(bats) do
      if bat:exists() then
        return false
      end
    end
    return true
  end

  bats = {}
  local ready_bats_count = 0
  local killed_bats_count = 0
  local camera_x, camera_y = camera:get_position()
  sol.timer.start(enemy, invoking_time, function()
    sprite:set_animation("playing")
  end)
  for index, position in ipairs(positions) do
    sol.timer.start(enemy, invoking_time * index, function()

      -- Create the bat and make it go the right position.
      local bat = create_bat(positions[index][1] + camera_x, positions[index][2] + camera_y)
      bat:start_positioning(positions[index][3] + camera_x, positions[index][4] + camera_y)

      -- Start throwing when all bats are ready.
      bat:register_event("on_positioned", function(bat)
        ready_bats_count = ready_bats_count + 1
        if ready_bats_count == #positions then
          sol.timer.start(enemy, additional_playing_time, function()
            start_throwing()
          end)
        end
      end)

      -- Make the boss defeated when all bats of a round are killed.
      bat:register_event("on_dead", function(bat)
        killed_bats_count = killed_bats_count + 1
        if killed_bats_count == #positions then
          start_escaping()
          return
        end
        if is_round_finished() then
          enemy:restart()
        end
      end)

      -- Wait a few time then restart if no more bats.
      bat:register_event("on_off_screen", function(bat)
        if is_round_finished() then
          enemy:restart()
        end
      end)
    end)
  end
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(1)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:start_shadow()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  -- States.
  enemy:set_invincible()
  enemy:set_can_attack(false)
  enemy:set_damage(0)

  if is_ready then
    sprite:set_animation("stopped")
    sol.timer.start(enemy, waiting_time, function()
      round_count = round_count + 1
      if enemy.on_round_begin then
        enemy:on_round_begin(round_count)
      end
      current_step = (current_step % #bat_positions) + 1
      start_invoking(bat_positions[current_step])
    end)
  else
    start_incoming()
  end
end)

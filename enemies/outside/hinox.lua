----------------------------------
--
-- Hinox Master.
--
-- Moves randomly over horizontal and vertical axis, then charge to the hero after some time.
-- Hold and throw the hero across the room if touched while charging, and throw a bomb to the hero if hurt.
-- 
--
-- Methods : enemy:start_walking()
--           enemy:start_charging()
--           enemy:throw_bomb() --> To merge with the following one
--           enemy:throw_hero()
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local camera = map:get_camera()
local sprite
local quarter = math.pi * 0.5
local is_bomb_upcoming = false
local is_hero_catchable = false
local holded_bomb = nil

-- Configuration variables
local skin = enemy:get_property("skin")
local waiting_duration = 400
local walking_angles = {0, quarter, 2.0 * quarter, 3.0 * quarter}
local walking_speed = 40
local walking_minimum_distance = 32
local walking_maximum_distance = 46
local charging_speed = 160
local charging_maximum_distance = 100
local charging_probability = 0.25
local frenzy_duration  = 1000

local right_hand_offset_x = -20
local right_hand_offset_y = -52
local bomb_holding_duration = 300
local bomb_throwing_duration = 800
local bomb_throwing_height = 60
local bomb_throwing_speed = 120
local hero_holding_duration = 800
local hero_throwing_duration = 800
local hero_throwing_height = 60
local hero_throwing_speed = 240
local hero_stunned_duration = 1000

-- Hold the given entity in the given hand and wait for the actual throw.
local function start_holding(right_hand, hold_duration, on_throwing)

  is_bomb_upcoming = false
  
  enemy:set_drawn_in_y_order(false) -- Display this enemy as a flat entity for the throw to draw the hero above.
  enemy:bring_to_front()
  sprite:set_animation("hurt") -- TODO make holding animation("holding_" .. (right_hand and "right" or "left"))
  --sprite:set_direction(right_hand and 2 or 0)

  sol.timer.start(enemy, hold_duration, function()
    on_throwing()
    sprite:set_animation("hurt") -- TODO make throwing animation ("throwing_" .. (right_hand and "right" or "left"))
    sol.timer.start(enemy, waiting_duration, function()
      enemy:restart()
    end)
  end)
end

-- Start the enemy walking movement.
function enemy:start_walking()

  enemy:start_straight_walking(walking_angles[math.random(4)], walking_speed, math.random(walking_minimum_distance, walking_maximum_distance), function()

    -- At the end of the move, wait a few time then randomly charge or restart another move.
    sol.timer.start(enemy, waiting_duration, function()
      if math.random() <= charging_probability then
        enemy:throw_bomb()
      else
        enemy:start_walking()
      end
    end)
  end)
end

-- Throw a bomb to the hero.
-- TODO Factorize.
function enemy:throw_bomb()

  enemy:stop_movement()
  sol.timer.stop_all(enemy)

  local x, y, layer = enemy:get_position()
  local hero_x, _ , hero_layer = hero:get_position()
  local is_right_hand_throw = hero_x > x
  local hand_offset_x = is_right_hand_throw and right_hand_offset_x or 0 - right_hand_offset_x

  -- Hold a bomb for some time and throw it.
  local bomb = enemy:create_enemy({
    name = (enemy:get_name() or enemy:get_breed()) .. "_bomb",
    breed = "projectiles/bomb",
    x = hand_offset_x
  })

  if bomb and bomb:exists() then -- If the bomb was not immediatly removed from the on_created() event.
    bomb:set_position(x + hand_offset_x, y)
    bomb:get_sprite():set_xy(0, right_hand_offset_y)
    holded_bomb = bomb

    start_holding(is_right_hand_throw, bomb_holding_duration, function()
      bomb:set_drawn_in_y_order(false) -- Display the bomb as flat entity until the throw.
      bomb:bring_to_front()

      -- Start the thrown movement to the hero.
      local angle = bomb:get_angle(hero)
      enemy:start_throwing(bomb, bomb_throwing_duration, -right_hand_offset_y, bomb_throwing_height, angle, bomb_throwing_speed, function()
        bomb:set_layer(hero_layer)
        bomb:explode()
      end)
      bomb:set_drawn_in_y_order()
      holded_bomb = nil
    end)
  end
end

-- Prepare to throw a bomb after restart when hurt.
enemy:register_event("on_hurt", function(enemy)

  is_bomb_upcoming = true

  -- Remove a possible holded bomb to throw the next one.
  if holded_bomb then
    holded_bomb:start_death()
  end
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(10)
  enemy:set_size(32, 32) -- Workaround : Adapt the size to never have a part of enemy sprite under ceiling nor holded hero over a wall.
  enemy:set_origin(16, 27)

  -- Set the requested skin to the enemy or the default one.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = 4,
  	boomerang = 2,
  	explosion = 1,
  	sword = 1,
  	thrown_item = 4,
  	fire = 4,
  	jump_on = "ignored",
  	hammer = 4,
  	hookshot = 2,
  	magic_powder = 4,
  	shield = "protected",
  	thrust = 2
  })

  -- States.
  is_hero_catchable = false
  enemy:set_damage(8)
  enemy:set_can_attack(true)
  enemy:set_obstacle_behavior("flying") -- Don't fall in holes.
  enemy:set_drawn_in_y_order() -- Reset y drawn order possibly changed by the throw.
  sprite:set_animation("shaking")
  if is_bomb_upcoming then
    enemy:throw_bomb()
  else
    sol.timer.start(enemy, waiting_duration, function()
      enemy:start_walking()
    end)
  end
end)

----------------------------------
--
-- Darknut.
--
-- Moves randomly over horizontal and vertical axis, and charge the hero if close enough.
-- Turn his head to the next direction before starting a new random move.
-- May start disabled and manually wake_up() from outside this script if initially stuck on a wall, in which case it will get away from overlapping obstacles before walking normally.
--
-- Methods : enemy:wake_up()
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
local is_charging = false
local is_waking_up = false

-- Configuration variables
local charge_triggering_distance = 80
local charging_speed = 56
local walking_angles = {0, quarter, 2.0 * quarter, 3.0 * quarter}
local walking_speed = 32
local walking_minimum_distance = 16
local walking_maximum_distance = 96
local waiting_duration = 1600
local waking_up_direction = 3
local waking_up_distance = 16
local waking_up_duration = 1000

-- Start the enemy charge movement.
local function start_charging()

  is_charging = true
  enemy:stop_movement()
  enemy:start_target_walking(hero, charging_speed)
  sprite:set_animation("walking")
	sol.audio.play_sound("hero_seen")
end

-- Start the enemy random movement.
local function start_walking(direction)

  direction = direction or math.random(4)
  enemy:start_straight_walking(walking_angles[direction], walking_speed, math.random(walking_minimum_distance, walking_maximum_distance), function()
    local next_direction = math.random(4)
    local waiting_animation = (direction + 1) % 4 == next_direction and "seek_left" or (direction - 1) % 4 == next_direction and "seek_right" or "immobilized"
    sprite:set_animation("looking_around")

    sol.timer.start(enemy, waiting_duration, function()
      if not is_charging then
        start_walking(next_direction)
      end
    end)
  end)
end

-- Wake the enemy up as invincible, start a little walk to get away from overlapping obstacles then restart.
function enemy:wake_up()

  is_waking_up = true
  sol.timer.stop_all(enemy)
  enemy:stop_movement()
  enemy:set_enabled(true)
  enemy:set_drawn_in_y_order(false) -- Draw the enemy below the explosion that woke him up.
  sprite:set_animation("immobilized")
  sprite:set_direction(waking_up_direction)

  enemy:set_hero_weapons_reactions({
  	arrow = "protected",
  	boomerang = "protected",
  	explosion = "ignored",
  	sword = "protected",
  	thrown_item = "protected",
  	fire = "protected",
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = "protected",
  	magic_powder = "ignored",
  	shield = "protected",
  	thrust = "protected"
  })

  sol.timer.start(enemy, waking_up_duration, function()
    local movement = enemy:start_straight_walking(waking_up_direction * quarter, walking_speed, waking_up_distance, function()
      is_waking_up = false
      enemy:set_drawn_in_y_order()
      enemy:restart()
    end)
    movement:set_ignore_obstacles()
  end)
end

-- Passive behaviors needing constant checking.
function enemy:check_hero()

  if enemy:is_immobilized() then
    return
  end

  -- Start charging if the hero is near enough
  if not is_charging and enemy:is_near(hero, charge_triggering_distance) then
    start_charging()
	elseif not enemy:is_near(hero, charge_triggering_distance) then
		start_walking()
  end

	sol.timer.start(enemy, 1000, function() enemy:check_hero() end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(2)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:hold_weapon("enemies/"..enemy:get_breed().."_weapon",enemy:get_sprite(), 0, 0)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = 2,
  	boomerang = 2,
  	explosion = 2,
  	sword = 1,
  	thrown_item = 2,
  	fire = 2,
  	jump_on = "ignored",
  	hammer = 2,
  	hookshot = 2,
  	magic_powder = 2,
  	shield = "protected",
  	thrust = 2
  })

  -- States.
  enemy:set_can_attack(true)
  enemy:set_damage(1)

	if is_charging and enemy:is_near(hero, charge_triggering_distance) then
		start_charging()
	else
		start_walking()
	end
	enemy:check_hero()
end)

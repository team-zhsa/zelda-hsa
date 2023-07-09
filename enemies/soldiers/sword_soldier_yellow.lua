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

-- Configuration variables
local charge_triggering_distance = 64
local charging_speed = 56
local walking_angles = {0, quarter, 2.0 * quarter, 3.0 * quarter}
local walking_speed = 32
local walking_minimum_distance = 16
local walking_maximum_distance = 96
local waiting_duration = 800

-- Start the enemy charge movement.
function start_charging()

  is_charging = true
  enemy:stop_movement()
  enemy:start_target_walking(hero, 0)
		sol.timer.start(enemy, 200, function()
			enemy:start_target_walking(hero, charging_speed)
		end)
  sprite:set_animation("walking")
	enemy:create_symbol_exclamation("hero_seen")
	sol.audio.play_sound("hero_seen")
end

function look_around()
	local looking_animation = "looking_around"
	local next_direction = math.random(4)
	sprite:set_animation(looking_animation)
	sol.timer.start(enemy, 1600, function()
		start_walking(next_direction)
	end)
end

-- Start the enemy random movement.
function start_walking(direction)
	is_charging = false
  direction = direction or math.random(4)
  enemy:start_straight_walking(walking_angles[direction], walking_speed, math.random(walking_minimum_distance, walking_maximum_distance), function()
		
		local waiting_animation = "immobilized"
		sprite:set_animation(waiting_animation)
		
    sol.timer.start(enemy, waiting_duration, function()
      if not is_charging then
				look_around()
      end
    end)
  end)
end

-- Passive behaviours needing constant checking.
enemy:register_event("on_update", function(enemy)

  if enemy:is_immobilized() then
    return
  end

  -- Start charging if the hero is near enough
  if not is_charging and enemy:is_near(hero, charge_triggering_distance) then
    start_charging()
	elseif is_charging and not enemy:is_near(hero, charge_triggering_distance) then
		start_walking()
  end
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(3)
  enemy:set_size(16, 16)
  enemy:set_origin(24, 29)
  enemy:hold_weapon("enemies/"..enemy:get_breed().."_weapon",enemy:get_sprite(), 0, 0)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = 3,
  	boomerang = "immobilized",
  	explosion = 3,
  	sword = 1,
  	thrown_item = 3,
  	fire = 3,
  	jump_on = "ignored",
  	hammer = 2,
  	hookshot = "immobilized",
  	magic_powder = "ignored",
  	shield = "protected",
  	thrust = 3
  })

  -- States.
  enemy:set_can_attack(true)
  enemy:set_damage(4)
	enemy:set_drawn_in_y_order()
	if is_charging then
		start_charging()
	else
		start_walking()
	end
end)
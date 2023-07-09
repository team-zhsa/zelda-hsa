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
local charge_triggering_distance = 64
local charging_speed = 56
local walking_angles = {0, quarter, 2.0 * quarter, 3.0 * quarter}
local walking_speed = 32
local walking_minimum_distance = 16
local walking_maximum_distance = 96
local waiting_duration = 800
local waiting__ = 50

-- Start the enemy charge movement.
function start_charging()

  is_charging = true
  enemy:stop_movement()
  enemy:start_target_walking(hero, charging_speed)
  sprite:set_animation("walking")
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

  enemy:set_life(2)
  enemy:set_size(16, 16)
  enemy:set_origin(24, 29)
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
  enemy:set_damage(2)
	enemy:set_drawn_in_y_order()
	if is_charging then
		start_charging()
	else
		start_walking()
	end
end)
--[[
function enemy:on_restarted()
	if not being_pushed then
		if going_hero then
			enemy:go_hero()
		else
			enemy:go_random()
			enemy:check_hero()
		end
	end
end

function enemy:check_hero()
	local map = enemy:get_map()
	local hero = map:get_hero()
	local _, _, layer = enemy:get_position()
	local _, _, hero_layer = hero:get_position()
	local near_hero = layer == hero_layer
			and enemy:get_distance(hero) < detect_distance
			and enemy:is_in_same_region(hero)

	if near_hero and not going_hero then
		enemy:go_hero()
	elseif not near_hero and going_hero then
		enemy:go_random()
	end
	sol.timer.stop_all(self)
	sol.timer.start(self, 1000, function() enemy:check_hero() end)
end

function enemy:on_movement_changed(movement)
	if not being_pushed then
		local direction4 = movement:get_direction4()
		main_sprite:set_direction(direction4)
		sword_sprite:set_direction(direction4)
	end
end

function enemy:on_movement_finished(movement)
	if being_pushed then
		enemy:go_hero()
	end
end

function enemy:on_obstacle_reached(movement)
	if being_pushed then
		enemy:go_hero()
	end
end

function enemy:on_custom_attack_received(attack, sprite)
	if attack == "sword" and sprite == sword_sprite then
		audio_manager:play_sound("sword_tapping")
		being_pushed = true
		local map = enemy:get_map()
		local hero = map:get_hero()
		local x, y = enemy:get_position()
		local angle = hero:get_angle(enemy)
		local movement = sol.movement.create("straight")
		movement:set_speed(128)
		movement:set_angle(angle)
		movement:set_max_distance(26)
		movement:set_smooth(true)
		movement:start(enemy)
	end
end

function enemy:go_random()
	local movement = sol.movement.create("random_path")
	movement:set_speed(normal_speed)
	movement:start(enemy)
	being_pushed = false
	going_hero = false
end

function enemy:go_hero()
	local movement = sol.movement.create("target")
	movement:set_speed(fast_speed)
	movement:start(enemy)
	audio_manager:play_sound("hero_seen")
	being_pushed = false
	going_hero = true
end

-- Prevent enemies from "piling up" as much, which makes it easy to kill multiple in one hit.
function enemy:on_collision_enemy(other_enemy, other_sprite, my_sprite)
	if enemy:is_traversable() then
		enemy:set_traversable(true) --default false
		sol.timer.start(200, function() enemy:set_traversable(true) end)
	end
end--]]
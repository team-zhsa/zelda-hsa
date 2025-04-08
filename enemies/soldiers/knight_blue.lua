----------------------------------
--
-- Spear red soldier.
--
-- Moves randomly over horizontal and vertical axis.
-- Throw a stone at the end of each walk step if the hero is on the direction the enemy is looking at.
-- Turn his head to the next direction before starting a new random move.
--
-- Methods : enemy:start_walking([direction])
--
----------------------------------

local enemy = ...
require("scripts/multi_events")
require("enemies/lib/weapons").learn(enemy)
	
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local quarter = math.pi * 0.5
local is_charging = false

-- Configuration variables.
local charge_triggering_distance = 80
local charging_speed = 56
local walking_angles = {0, quarter, 2.0 * quarter, 3.0 * quarter}
local walking_speed = 48
local walking_minimum_distance = 16
local walking_maximum_distance = 32
local waiting_duration = 800
local throwing_duration = 200

local projectile_breed = "projectiles/spear"
local projectile_offset = {{0, -14}, {6, -4}, {0, -14}, {-1, -4}}

-- Start the enemy charge movement.
function enemy:start_charging()
  is_charging = true
  enemy:stop_movement()
  enemy:start_target_walking(hero, charging_speed)
  sprite:set_animation("walking")
	sol.audio.play_sound("hero/hero_seen")
end

-- Start the enemy movement.
function enemy:start_walking(direction)
  is_charging = false
	direction = direction or math.random(4)
	enemy:start_straight_walking(walking_angles[direction], walking_speed, math.random(walking_minimum_distance, walking_maximum_distance), function()
		local next_direction = math.random(4)
		local waiting_animation = "looking_around"
		sprite:set_animation(waiting_animation)
		sol.timer.start(enemy, waiting_duration, function()
			-- Throw an arrow if the hero is on the direction the enemy is looking at.
			if enemy:get_direction4_to(hero) == sprite:get_direction() then
				enemy:throw_projectile(projectile_breed, throwing_duration, projectile_offset[direction][1], projectile_offset[direction][2], function()
					enemy:start_walking(next_direction)
				end)
			else
				enemy:start_walking(next_direction)
			end
		end)
	end)
end

-- Passive behaviors needing constant checking.
function enemy:check_hero()
  if enemy:is_immobilized() then
    return
  end
  -- Start charging if the hero is near enough
  if not is_charging and enemy:is_near(hero, charge_triggering_distance) then
    enemy:start_charging()
	elseif is_charging and not enemy:is_near(hero, charge_triggering_distance) then
		enemy:start_walking()
	elseif is_charging and enemy:is_near(hero, charge_triggering_distance) then
		enemy:throw_projectile(projectile_breed, throwing_duration, projectile_offset[math.random(4)][1], projectile_offset[math.random(4)][2], function()
			enemy:start_walking()
		end)
  end
	sol.timer.start(enemy, 1000, function() enemy:check_hero() end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)
	enemy:hold_weapon("enemies/soldiers/knight_spear", enemy:get_sprite(), 0, 0)
	enemy:set_life(4)
	enemy:set_size(16, 16)
	enemy:set_origin(8, 13)
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
	enemy:set_damage(8)
	if is_charging and enemy:is_near(hero, charge_triggering_distance) then
		enemy:start_charging()
	else
		enemy:start_walking()
	end
	enemy:check_hero()
end)
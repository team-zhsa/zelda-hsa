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

-- Configuration variables.
local walking_angles = {0, quarter, 2.0 * quarter, 3.0 * quarter}
local walking_speed = 48
local walking_minimum_distance = 16
local walking_maximum_distance = 32
local waiting_duration = 800
local throwing_duration = 200

local projectile_breed = "projectiles/spear"
local projectile_offset = {{0, -10}, {6, 0}, {0, -10}, {-1, 0}}

-- Start the enemy movement.
function enemy:start_walking(direction)

	direction = direction or math.random(4)
	enemy:start_straight_walking(walking_angles[direction], walking_speed, math.random(walking_minimum_distance, walking_maximum_distance), function()
		local next_direction = math.random(4)
		local waiting_animation = "immobilized"
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

-- Initialization.
enemy:register_event("on_created", function(enemy)

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
	enemy:start_walking()
end)
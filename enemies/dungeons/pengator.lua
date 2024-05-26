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
local is_waiting = false

-- Configuration variables
local charge_triggering_distance = 80
local charging_speed = 56
local walking_angles = {0, quarter, 2.0 * quarter, 3.0 * quarter}
local walking_speed = 24
local walking_distance = 16
local walking_maximum_distance = 96
local sliding_distance = 24

-- Start the enemy charge movement.
function enemy:start_charging()

  is_charging = true
  enemy:stop_movement()
  sprite:set_animation("sliding")
  local movement = sol.movement.create("straight")
  local angle = walking_angles[math.random(4)]
  movement:set_speed(128)
  movement:set_max_distance(sliding_distance)
  movement:set_angle(angle)
  movement:start(enemy, function()
    enemy:start_walking(math.random(4))
  end)
end

-- Start the enemy random movement.
function enemy:start_walking(direction)
  is_charging = false
  direction = direction or math.random(4)
  enemy:start_straight_walking(walking_angles[direction], walking_speed, walking_minimum_distance, function()
    local next_direction = math.random(4)
    enemy:start_charging()
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
  end

	sol.timer.start(enemy, 1000, function() enemy:check_hero() end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(8)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)

end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = 2,
  	boomerang = "immobilized",
  	explosion = 4,
  	sword = 1,
  	thrown_item = 8,
  	fire = 4,
  	jump_on = "ignored",
    ice = 0,
  	hammer = 8,
  	hookshot = "immobilized",
  	magic_powder = "ignored",
  	shield = "protected",
  	thrust = 8
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
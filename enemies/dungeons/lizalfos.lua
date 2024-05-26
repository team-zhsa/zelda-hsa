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
local walking_speed = 32
local walking_minimum_distance = 16
local walking_maximum_distance = 96
local waiting_duration = 1600

-- Start the enemy charge movement.
local function start_charging()

  is_charging = true
  enemy:stop_movement()
  enemy:start_target_walking(hero, charging_speed)
  sprite:set_animation("walking")
	sol.audio.play_sound("hero/hero_seen")
end

-- Start the enemy random movement.
local function start_walking(direction)
  is_charging = false
  direction = direction or math.random(4)
  enemy:start_straight_walking(walking_angles[direction], walking_speed, math.random(walking_minimum_distance, walking_maximum_distance), function()
    local next_direction = math.random(4)
    if not is_charging then
      start_walking(next_direction)
    end
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
	elseif is_charging and not enemy:is_near(hero, charge_triggering_distance) then
		start_walking()
  end

	sol.timer.start(enemy, 1000, function() enemy:check_hero() end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(6)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:hold_weapon("enemies/dungeons/lizalfos_sword", enemy:get_sprite(), 0, 0)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = 2,
  	boomerang = "immobilized",
  	explosion = 6,
  	sword = 1,
  	thrown_item = 6,
  	fire = 6,
  	jump_on = "ignored",
    ice = 0,
  	hammer = 2,
  	hookshot = "immobilized",
  	magic_powder = "ignored",
  	shield = "protected",
  	thrust = 6
  })

  -- States.
  enemy:set_can_attack(true)
  enemy:set_damage(2)

	if is_charging and enemy:is_near(hero, charge_triggering_distance) then
		start_charging()
	else
		start_walking()
	end
	enemy:check_hero()
end)
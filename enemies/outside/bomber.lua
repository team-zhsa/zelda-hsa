----------------------------------
--
-- Bomber.
--
-- Flying enemy moving randomly over horizontal and vertical axis, and stand off when the hero attacks too close.
-- Regularly throw a bomb to the hero.
--
----------------------------------

-- Global variables
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local eighth = math.pi * 0.25
local sixteenth = math.pi * 0.125
local attacking_timer = nil

-- Configuration variables
local area = enemy:get_property("area")
local flying_speed = 32
local flying_minimum_distance = 16
local flying_maximum_distance = 96
local flying_height = 16
local throwing_bomb_minimum_delay = 1500
local throwing_bomb_maximum_delay = 3000
local stand_off_triggering_distance = 48
local stand_off_speed = 200
local stand_off_distance = 32

local bomb_throw_duration = 500
local bomb_throw_height = 20
local bomb_throw_speed = 80
local firing_duration = 500

-- Return the angle from the enemy sprite to given entity.
local function get_angle_from_sprite(sprite, entity)

  local x, y, _ = enemy:get_position()
  local sprite_x, sprite_y = sprite:get_xy()
  local entity_x, entity_y, _ = entity:get_position()

  return math.atan2(y - entity_y + sprite_y, entity_x - x - sprite_x)
end

-- Start the enemy movement.
local function start_flying()

  -- Choose an angle in pi/4 multiples depending on a random position of the enemy's area.
  local random_x, random_y = enemy:get_random_position_in_area(area or camera)
  local angle = math.floor((enemy:get_angle(random_x, random_y) + sixteenth) / eighth) * eighth

  sprite:set_animation("flying")
  local movement = enemy:start_straight_walking(angle, flying_speed, math.random(flying_minimum_distance, flying_maximum_distance), function()
    start_flying()
  end)
  movement:set_ignore_obstacles()
end

-- Start throwing bomb.
local function start_attacking()

  if attacking_timer then
    attacking_timer:stop()
  end

  -- Throw a bomb periodically.
  attacking_timer = sol.timer.start(enemy, math.random(throwing_bomb_minimum_delay, throwing_bomb_maximum_delay), function()

    local bomb = enemy:create_enemy({
      name = (enemy:get_name() or enemy:get_breed()) .. "_bomb",
      breed = "projectiles/bomb"
    })

    if bomb and bomb:exists() then -- If the bomb was not immediatly removed from the on_created() event.
      local angle = get_angle_from_sprite(sprite, hero)
      enemy:start_throwing(bomb, bomb_throw_duration, flying_height, bomb_throw_height, angle, bomb_throw_speed, function()

        -- Check the ground on the lowest possible layer.
        local x, y, layer = bomb:get_position()
        local ground = "empty"
        for ground_layer = enemy:get_layer(), map:get_min_layer(), -1 do
          ground = map:get_ground(x, y, ground_layer)
          if ground ~= "empty" then
            break
          end
        end

        -- Remove the bomb on bouncing on a bad ground, else make it explode.
        if ground == "deep_water" then
          bomb:start_brief_effect("entities/ground_effects/water")
          bomb:start_death()
        elseif ground == "hole" then
          bomb:start_brief_effect("entities/ground_effects/falling_on_hole")
          bomb:start_death()
        elseif ground == "lava" then
          bomb:start_brief_effect("entities/ground_effects/lava")
          bomb:start_death()
        else
          bomb:explode()
        end
      end)
    end

    sprite:set_animation("firing")
    sol.timer.start(enemy, firing_duration, function()
      sprite:set_animation("flying")
    end)

    return math.random(throwing_bomb_minimum_delay, throwing_bomb_maximum_delay)
  end)
end

-- Start the enemy stand off movement.
local function start_stand_off()

  local movement = enemy:start_straight_walking(get_angle_from_sprite(sprite, hero) + math.pi, stand_off_speed, stand_off_distance, function()
    start_flying()
  end)
  movement:set_ignore_obstacles()
end

-- Go away when attacking too close.
map:register_event("on_command_pressed", function(map, command)

  if not enemy:exists() or not enemy:is_enabled() then
    return
  end

  if not enemy.is_exhausted then
    if enemy:is_near(hero, stand_off_triggering_distance, sprite) and (command == "attack" or command == "item_1" or command == "item_2") then
      start_stand_off()
    end
  end
end)

-- Initialization.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(3)
  enemy:set_size(32, 24)
  enemy:set_origin(16, 21)
  enemy:start_shadow()
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = 3,
  	boomerang = 3,
  	explosion = "ignored",
  	sword = 1,
  	thrown_item = "protected",
  	fire = 3,
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = "protected",
  	magic_powder = 3,
  	shield = "protected",
  	thrust = 2
  })

  -- States.
  enemy:set_layer_independent_collisions(true)
  enemy:set_can_attack(true)
  enemy:set_damage(4)
  start_flying()
  start_attacking()
  sprite:set_xy(0, -flying_height) -- Directly fly without taking off movement.
end)

----------------------------------
--
-- Octorok.
--
-- Moves randomly over horizontal and vertical axis.
-- Throw a stone at the end of each walk step if the hero is on the direction the enemy is looking at.
--
-- Methods : enemy:start_walking()
--
----------------------------------

local enemy = ...
require("scripts/multi_events")
require("enemies/lib/weapons").learn(enemy)
local audio_manager=require("scripts/audio_manager")
  
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
local waiting_duration = 400
local throwing_duration = 200

local projectile_breed = "projectiles/stone"
local projectile_offset = {{0, -8}, {0, -8}, {0, -8}, {0, -8}}

-- Start the enemy movement.
function enemy:start_walking()

  local direction = math.random(4)
  enemy:start_straight_walking(walking_angles[direction], walking_speed, math.random(walking_minimum_distance, walking_maximum_distance), function() 
    sprite:set_animation("immobilized")
    sol.timer.start(enemy, waiting_duration, function()

      -- Throw a stone if the hero is on the direction the enemy is looking at.
      if enemy:get_direction4_to(hero) == sprite:get_direction() then
        enemy:throw_projectile(projectile_breed, throwing_duration, projectile_offset[direction][1], projectile_offset[direction][2], function()
          audio_manager:play_entity_sound(enemy, "octorok")
          enemy:start_walking()
        end)
      else
        enemy:start_walking()
      end
    end)
  end)
end

-- Initialization.
enemy:register_event("on_created", function(enemy)
  enemy:set_life(10)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_fire_reaction_sprite(sprite, reaction)
end)

-- Restart settings.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = 1,
  	boomerang = "immobilized",
  	explosion = 1,
  	sword = 1,
  	thrown_item = 1,
    fire = "immobilized",
  	jump_on = "ignored",
  	hammer = 1,
  	hookshot = 1,
  	magic_powder = 1,
  	shield = "protected",
  	thrust = 1
  })

  -- States.
  enemy:set_can_attack(true)
  enemy:set_damage(1)
  enemy:start_walking()
end)
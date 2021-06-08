----------------------------------
--
-- Buzz Blob.
--
-- Randomly goes over 8 directions and electrocute the hero when attacked by sword or thrust.
-- Transform into Cukeman on magic powder attack received.
--
----------------------------------

-- Global variables.
local enemy = ...
require("enemies/lib/common_actions").learn(enemy)
local effect_model = require("scripts/gfx_effects/electric")
local audio_manager = require("scripts/audio_manager")

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
local eighth = math.pi * 0.25

-- Configuration variables

local h_speed = 72
local v_speed = 32

function enemy:start_walking()
  enemy:get_sprite():set_animation("walking")
  local m = sol.movement.create("random_path")
	if m:get_angle() == 0 or math.pi then
		m:set_speed(h_speed)
	else
		m:set_speed(v_speed)
	end
  m:start(self)
end

-- The enemy appears: set its properties.
enemy:register_event("on_created", function(enemy)

  enemy:set_life(2)
end)

-- The enemy appears: set its properties.
enemy:register_event("on_restarted", function(enemy)

  enemy:set_hero_weapons_reactions({
  	arrow = 1,
  	boomerang = 1,
  	explosion = 1,
  	sword = 1,
  	thrown_item = "protected",
  	fire = 1,
  	jump_on = "ignored",
  	hammer = "protected",
  	hookshot = "immobilized",
  	shield = "protected",
  	thrust = 1
  })

  -- States.
  enemy:set_damage(6)
  enemy:start_walking()
end)

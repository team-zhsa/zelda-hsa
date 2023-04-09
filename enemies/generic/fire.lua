-- Lua script of enemy fire.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

-- Event called when the enemy is initialised.
function enemy:on_created()

  -- initialise the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("entities/fire")
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_invincible(true)
end


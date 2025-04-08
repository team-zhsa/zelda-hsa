-- Lua script of enemy boss/d17_boss_3.
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
  sprite = enemy:create_sprite("enemies/ganon_3")
  enemy:set_life(1000)
  enemy:set_damage(128)
  enemy:set_size(628, 496)
  enemy:set_traversable(false)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_attack_consequence("arrow", "custom")
end


-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()

  movement = sol.movement.create("path")
  movement:set_path{6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,}
  movement:set_speed(30)
  self:start_movement(movement)
  movement:start(enemy)
  path_movement:set_loop(true)
end

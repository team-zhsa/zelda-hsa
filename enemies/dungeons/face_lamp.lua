-- Lua script of enemy face_lamp.
-- This script is executed every time an enemy with this model is created.

-- Variables
local enemy = ...
local behavior = require("enemies/lib/fire_breathing_statue")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  projectile_breed = "projectiles/fireball",
  projectile_sound = "zora",
}

behavior:create(enemy, properties)

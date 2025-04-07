local enemy = ...

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 2,
  damage = 2,
  normal_speed = 64,
  faster_speed = 64,
  obstacle_behavior = "swimming",  -- Allow to traverse water.
}

behavior:create(enemy, properties)

enemy:set_random_treasures(
  { "arrow", 2 },
  { "rupee", 2 },
  { "heart", 1 }
)

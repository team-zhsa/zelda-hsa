local enemy = ...
local behavior = require("enemies/generic/soldier")

-- Blue knight soldier.

local properties = {
  main_sprite = "enemies/blue_knight_soldier",
  sword_sprite = "enemies/blue_knight_soldier_sword",
  life = 6,
  damage = 6,
  normal_speed = 40,
  faster_speed = 48,
  play_hero_seen_sound = true
}

behavior:create(enemy, properties)
local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Blue Hardhat Beetle.

local properties = {
  sprite = "enemies/hardhat_beetle_blue",
  life = 8,
  damage = 8,
  normal_speed = 32,
  faster_speed = 48,
  push_hero_on_sword = true
}
behavior:create(enemy, properties)

enemy:set_attack_consequence("fire", 1)
local enemy = ...
local behavior = require("enemies/generic/lizalfos")

-- Lizalfos.

local properties = {
  main_sprite = "enemies/dungeons/lizalfos_red",
  life = 4,
  damage = 6,
  normal_speed = 24,
  faster_speed = 32,
}

behavior:create(enemy, properties)
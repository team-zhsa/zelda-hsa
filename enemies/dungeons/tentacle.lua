local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Tentacle.

local properties = {
  sprite = "enemies/dungeons/tentacle",
  life = 2,
  damage = 2,
  normal_speed = 16,
  faster_speed = 16,
  movement_create = function()
    return sol.movement.create("path_finding")
  end
}
behavior:create(enemy, properties)
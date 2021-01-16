local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Tentacle Boss, twice bigger than regular ones.

local properties = {
  sprite = "enemies/boss/tentacle_boss",
  life = 16,
  damage = 2,
  normal_speed = 32,
  faster_speed = 32,
	hurt_style = "boss",
  movement_create = function()
    return sol.movement.create("path_finding")
  end
}

function enemy:on_started()
	  self:set_size(32, 32)
end

behavior:create(enemy, properties)
----------------------------------
--
-- A carriable entity that can be thrown and bounce like a bottle.
--
----------------------------------

local bottle = ...
local carriable_behavior = require("entities/lib/carriable")
carriable_behavior.apply(bottle, {bounce_sound = "items/shield", respawn_delay = 2000})
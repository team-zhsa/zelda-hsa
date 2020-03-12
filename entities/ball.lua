----------------------------------
--
-- A carriable entity that can be thrown and bounce like a ball.
--
----------------------------------

local ball = ...
local carriable_behavior = require("entities/lib/carriable")
carriable_behavior.apply(ball, {bounce_sound = "items/shield", respawn_delay = 2000})
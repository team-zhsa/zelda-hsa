-- Lua script of map inside/caves/pop_cave.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hud = require("scripts/hud/hud")

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	game:set_hud_enabled(false)
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

local overlay = sol.surface.create("menus/prince_title.png") -- Fog image

function map:on_draw(dst_surface)
	overlay:draw(dst_surface)
	overlay:set_opacity(255) -- Feel free to change that value, default 255
end

function map:on_finished()
	game:set_hud_enabled(true)
end
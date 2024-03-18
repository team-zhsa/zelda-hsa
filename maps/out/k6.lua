local map = ...
local game = map:get_game()
local fog_manager = require("scripts/maps/fog_manager")
map:register_event("on_started", function()
	fog_manager:set_overlay("forest")
  game:show_map_name("faron_woods")
  map:set_digging_allowed(true)
end)
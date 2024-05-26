require("scripts/multi_events")
local function initialise_version_check_features(game)

end

-- Set up the version checker menu on any game that starts.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", initialise_version_check_features)
return true
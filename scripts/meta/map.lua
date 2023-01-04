-- Initialize Map behavior specific to this quest.

-- Variables
local map_meta = sol.main.get_metatable("map")

-- Include scripts
require ("scripts/multi_events")
local audio_manager = require("scripts/audio_manager")




local transition_finished_callback
function map_meta:wait_on_next_map_opening_transition_finished(callback)
  assert(type(callback) == 'function')
  transition_finished_callback = callback
end

map_meta:register_event("on_opening_transition_finished", function(map, destination)
    --print("End of built-in transition")

    local game = map:get_game()
    local hero = map:get_hero()
    local ground
    if game:get_value("tp_ground") == "hole" then
      hero:fall_from_ceiling(120, "jump", function()
        hero:play_ground_effect()
      end)
    end

    --call pending callback if any
    if transition_finished_callback then
      transition_finished_callback(map, destination)
      transition_finished_callback = nil
    end

end)

map_meta:register_event("on_started", function(map)
  local game = map:get_game()
  local hero = map:get_hero()
  hero.respawn_point_saved=nil
  local ground
  if game:get_value("tp_ground") == "hole" then
    hero:set_visible(false)
  else
    hero:set_visible()
  end

end)

map_meta:register_event("on_finished", function(map)
  if map:get_hero():is_running() then
    map:get_game().needs_running_restoration = true
  end
end)
require "scripts/multi_events"

local cs_meta=sol.main.get_metatable("state")

cs_meta:register_event("on_finished", function(state)
    -- print "state finished"
    local hero=state:get_map():get_hero()
    hero:set_previous_state("custom", state:get_description())
  end)

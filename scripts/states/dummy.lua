--A dummy empty testing state, with minimal code

local state = sol.state.create("dummy")

state:set_can_use_stream(false)
state:set_can_control_movement(true)
state:set_can_control_direction(false)

function state:on_started()
  print "Entering dummy state"
end

function state:on_finished()
  print "Exiting dummy state"
end

return function(e)
  print "Launching dummy state"
  e:start_state(state)
end


local map = ...
local game = map:get_game()
local separator_manager = require("scripts/maps/separator_manager.lua")
local timer_manager = require("scripts/maps/timer_manager")

map:register_event("on_started", function()
  separator_manager:manage_map(map)
	map:set_doors_open("door_23_n", false)
end)

sensor_18_door:register_event("on_activated", function()
  map:set_doors_open("door_23_n", true)
end)

sensor_23_door:register_event("on_activated", function()
  switch_door_23:set_activated(false)
  if hero:get_direction() == 3 then
      map:close_doors("door_23_n")  
  end
end)

switch_door_23:register_event("on_activated", function()
  map:open_doors("door_23_n")
  timer_manager:start_timer(map, 15000, "countdown", true, true, function() --Timer for 15 seconds
    map:close_doors("door_23_n")
    switch_door_23:set_activated(false)
  end,
  function()
    print("AAAA")  
  end)
end)
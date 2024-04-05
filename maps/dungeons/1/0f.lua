local map = ...
local game = map:get_game()
local separator_manager = require("scripts/maps/separator_manager.lua")
local timer_manager = require("scripts/maps/timer_manager")

map:register_event("on_started", function()
  separator_manager:manage_map(map)
	map:set_doors_open("door_23_n", false)
end)

switch_door_22:register_event("on_activated", function()
  map:open_doors("door_23_n1")
  timer_manager:start_timer(map, 15000, "countdown", function() --Timer for 15 seconds
    map:close_doors("door_23_n")
    switch_door_22:set_activated(false)
  end)
end)
local map = ...
local game = map:get_game()

local mdog = sol.movement.create("random_path")
mdog:set_speed(30)
mdog:start(dog)
mdog:start(goat)
-- Lua script of map dungeons/2/copy_protect.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()

  -- You can initialise the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

local switch_index = 0
local switches = {"switch_a", "switch_b", "switch_c", "switch_d"} --I had several NPCs that you needed to interact with in a certain order

for entity in map:get_entities("switch_") do
  function entity:on_activated() --or, entity:on_dead() for enemies, entity:on_activated() for switches, etc.
    map:process_switch(self:get_name())
  end
end

function map:process_switch(name)
	if switch_index then
  	if switches[switch_index] == name then
    	switch_index = switch_index + 1
    	--show some feedback here so they player knows they did something
    	sol.audio.play_sound("switch")
    	if switch_index == (#switches + 1) then
      	--do whatever happens when you do all the things in the right order:
      	sol.audio.play_sound("switch")
      	map:open_doors("skull_door")
    	end
  	else
    	--if the player hits one out of order:
    	sol.audio.play_sound("common/wrong")
    	switch_index = 0
  	end
	end
end
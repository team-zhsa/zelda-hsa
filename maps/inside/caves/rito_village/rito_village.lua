-- Lua script of map inside/caves/rito_village/rito_village.
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
--[[ Tournoi du plus fort TODO
  Round 1 : 5 Popo + 2 like like
Round 2 : 8 stallfoss
Round 3 : 2 lynel + 3 moblin rouges + 4 tetkite 
Round 4: 12 tetkite verte 
Round 5: 3 dodongo
Round 6: 9 bari
Round 7: 1 lamnola 
Round 8: 4 grosse bari + 2 Zola
Round 9: 2 lynel bleus
Round 10: le champion piaf varuna!
Hp : 56
Dmg : 17
Tire des flèches et se tient a distance .
Il invoque des bourrasques
--]]
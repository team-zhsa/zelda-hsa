-- Lua script of map out/f1 - f2 - g1 - g2 - h1 - h2 - i1 - i2.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function dungeon_3_door:on_interaction()
  if game:is_dungeon_finished(1) then
    game:start_dialog("telepathic_booth.not_working")
  elseif not game:has_item("bow") then
    game:start_dialog("telepathic_booth.go_sahasrahla", game:get_player_name())
  elseif not game:is_dungeon_finished(2) then
    game:start_dialog("telepathic_booth.go_twin_caves", game:get_player_name())
  elseif not game:get_item("rupee_bag"):has_variant(2) then
    game:start_dialog("telepathic_booth.dungeon_2_not_really_finished", game:get_player_name())
  elseif not game:is_dungeon_finished(3) then
    game:start_dialog("telepathic_booth.go_master_arbror", game:get_player_name())
  elseif not game:is_dungeon_finished(4) then
    game:start_dialog("telepathic_booth.go_billy", game:get_player_name())
  else
    game:start_dialog("telepathic_booth.shop", game:get_player_name())
  end
end
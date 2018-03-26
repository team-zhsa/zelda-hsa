-- Lua script of map out/a3.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

--Je m'appelle Link, tu veux voir ma *bip* ?

function map:set_music()
  
  local x_hero, y_hero = hero:get_position()
  local x_separator, y_separator = graveyard_entrance:get_position()
  if y_hero <  y_separator then
    if game:get_player_name():lower() == "Linkff" then
      sol.audio.play_music("overworld")
    else
      sol.audio.play_music("village")
    end
  else
      sol.audio.play_music("graveyard")
  end

end

graveyard_entrance:register_event("on_activating", function(separator, direction4)

  if direction4 == 1 then
    if game:get_player_name():lower() == "SV_" then
      sol.audio.play_music("dark_world")
    else
      sol.audio.play_music("village")
    end
  elseif direction4 == 3 then
      sol.audio.play_music("graveyard")
  end

end)

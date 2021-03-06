-- Lua script of map inside/castle/rooms.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
function map:jump_from_bed()
  hero:set_enabled(true)
  hero:start_jumping(7, 24, true)
  game:set_pause_allowed(true)
  bed:get_sprite():set_animation("empty_open")
  game:set_starting_location("inside/castle/rooms", "start_game")
  sol.audio.play_sound("hero_lands")
end

function map:wake_up()
  bed:get_sprite():set_animation("hero_waking")
  sol.timer.start(1000, function() 
    game:start_dialog("maps.houses.hyrule_castle.waking_up", function()
      sol.timer.start(500, function()
        map:jump_from_bed()
      end)
    end)
  end)
end

-- Events

function map:on_started(destination)
  if destination:get_name() == "start_game" then
    -- the intro scene is playing
    game:set_hud_enabled(true)
    game:set_pause_allowed(false)
    bed:get_sprite():set_animation("hero_sleeping")
    hero:freeze()
    hero:set_enabled(false)
    sol.audio.play_music("cutscenes/raining")
    sol.timer.start(3000, function()
      game:set_step_done("game_started")
      map:jump_from_bed()
    end)
  end
	if not game:is_step_done("sword_obtained") then
		sol.audio.play_music("cutscenes/raining")
		npc_zelda:set_enabled(true)
	else
		npc_zelda:set_enabled(false)
	end
end

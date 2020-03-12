-- Lua script of map dungeons/2/1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	boss_2:set_enabled(false)
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function s_28_1:on_activated()
  if s_28_2:is_activated() and s_28_3:is_activated() and s_28_4:is_activated() then
    map:open_doors("27_n_d")
    sol.audio.play_sound("common/secret_discover_minor")
  end
end

-- When stalfos boss 1 is dead, create a stalfos knight.

function boss_1:on_dead()

	boss_2:set_enabled(true)
end
	
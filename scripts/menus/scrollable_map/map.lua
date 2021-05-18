-- Script that creates a map menu for a game.

-- Usage:
-- require("scripts/menus/map")

require("scripts/multi_events")

-- Creates a map menu for the specified game.
local function initialize_map_features(game)

  if game.map_menu ~= nil then
    -- Already done.
    return
  end

  local scrollable_map = require("scripts/menus/scrollable_map/scrollable_map")

  local map_menu = {}
  game.map_menu = map_menu

  function map_menu:on_started()
    -- Define the available submenus.
    	game.map_submenus = {  -- Array of submenus (inventory, map, etc.).
      	scrollable_map:new(game),
    	}
    -- Select the submenu that was saved if any.
    local submenu_index = game:get_value("map_last_submenu") or 1
    if submenu_index <= 0
        or submenu_index > #game.map_submenus then
      submenu_index = 1
    end
    game:set_value("map_last_submenu", submenu_index)

    -- Play the sound of pausing the game.
    sol.audio.play_sound("menu/pause_open")
    -- Start the selected submenu.
    sol.menu.start(map_menu, game.map_submenus[submenu_index])
  end

  function map_menu:open()
    sol.menu.start(game, map_menu, true)
		game:set_suspended(true)
  end

  function map_menu:close()
    sol.menu.stop(map_menu)
		game:set_suspended(false)
  end

  function map_menu:on_finished()

    -- Play the sound of unpausing the game.
    sol.audio.play_sound("menu/pause_close")
    game.map_submenus = {}
    -- Restore opacity
    game:get_hud():set_item_icon_opacity(1, 255)
    game:get_hud():set_item_icon_opacity(2, 255)
    -- Restore the built-in effect of action and attack commands.
    if game.set_custom_command_effect ~= nil then
      game:set_custom_command_effect("action", nil)
      game:set_custom_command_effect("attack", nil)
    end
  end

  game:register_event("on_key_pressed", function(game, key, modifiers)
		if key == "w" then
			if not sol.menu.is_started(map_menu) == true and not game:is_paused(true) then
			-- Prevents from loading map if paused.
    		map_menu:open()
			elseif sol.menu.is_started(map_menu) == true and not game:is_paused(true) then
				map_menu:close()
			end
		end
  end)

end

-- Set up the map menu on any game that starts.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", initialize_map_features)

return true
-- Main Lua script of the quest.

require("scripts/features")
local shader_manager = require("scripts/shader_manager")
local initial_menus_config = require("scripts/initial_menus/menus_config")
local initial_menus = {}
local effect_manager = require('scripts/maps/effect_manager')
local tft = require('scripts/maps/tft_effect')
local fsa = require('scripts/maps/fsa_effect')

-- This function is called when Solarus starts.
function sol.main:on_started()
  sol.main.load_settings()
  math.randomseed(os.time())
  sol.video.set_window_size(320,240)

  -- Show the initial menus.
  if #initial_menus_config == 0 then
    return
  end

  for _, menu_script in ipairs(initial_menus_config) do
    initial_menus[#initial_menus + 1] = require(menu_script)
  end

  local on_top = false  -- To keep the debug menu on top.
  sol.menu.start(sol.main, initial_menus[1], on_top)
  for i, menu in ipairs(initial_menus) do
    function menu:on_finished()
      if sol.main.game ~= nil then
        -- A game is already running (probably quick start with a debug key).
        return
      end
      local next_menu = initial_menus[i + 1]
      if next_menu ~= nil then
        sol.menu.start(sol.main, next_menu)
      end
    end
  end

	local ceiling_drop_manager = require("scripts/maps/ceiling_drop_manager")
  for _, entity_type in pairs({"hero", "pickable", "block"}) do
    ceiling_drop_manager:create(entity_type)
  end

end

-- Event called when the program stops.
function sol.main:on_finished()

  sol.main.save_settings()
end

-- Event called when the player pressed a keyboard key.
function sol.main:on_key_pressed(key, modifiers)
  local game = sol.main.get_game()
  local handled = false
  --[[  local key_table = {}
  table.insert(key_table, key)
  print(table.concat(key_table))--]]
  if key == "f11" or
    (key == "return" and (modifiers.alt or modifiers.control)) then
    -- F11 or Ctrl + return or Alt + Return: switch fullscreen.
    sol.video.set_fullscreen(not sol.video.is_fullscreen())
    handled = true
  elseif key == "f4" and modifiers.alt then
    -- Alt + F4: stop the program.
    sol.main.exit()
    handled = true
  elseif key == "escape" and sol.main.game == nil then
    -- Escape in title screens: stop the program.
    sol.main.exit()
    handled = true
	elseif key == "f5" then
      -- F5: Change the shader.
      shader_manager:switch_shader()
      handled = true
    elseif key == 'f7' then
      -- F7: Set Four Swords Adventure mode.
      effect_manager:set_effect(game, fsa)
      game:set_value("mode", "fsa")
      handled = true
  		print("Mode FSA")  
    elseif key == 'f8' then
      -- F8: Set SNES mode (i.e. normal mode)
      game:set_value("mode", "snes")
      effect_manager:set_effect(game, nil)
      handled = true
  		print("Mode SNES")
    elseif key == 'f9' then
      -- F9: Set TFT mode.
      game:set_value("mode", "tft")
      effect_manager:set_effect(game, tft)
      handled = true
  		print("Mode TFT")
  end

  return handled
end

-- Starts a game.
function sol.main:start_savegame(game)

  -- Skip initial menus if any.
  for _, menu in ipairs(initial_menus) do
    sol.menu.stop(menu)
  end

  sol.main.game = game
  game:start()
end

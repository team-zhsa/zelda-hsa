-- Script that creates a game ready to be played.

-- Usage:
-- local game_manager = require("scripts/game_manager")
-- local game = game_manager:create("savegame_file_name")
-- game:start()
require("scripts/multi_events")
local initial_game = require("scripts/initial_game")
local game_manager = {}
local destructible_meta = sol.main.get_metatable("destructible")
local boundaries = sol.main.get_metatable("sensor")
local tone_manager = require("scripts/maps/daytime_manager")
local condition_manager = require("scripts/hero_condition")
local map_name = require("scripts/hud/map_name")
local field_music = require("scripts/maps/hyrule_field")
local effect_manager = require('scripts/maps/effect_manager')
local gb = require('scripts/maps/gb_effect')
local fsa = require('scripts/maps/fsa_effect')
time_flow = 1000

-- Creates a game ready to be played.
function game_manager:create(file)
	product_key = math.random(1000, 9999)
  -- Create the game (but do not start it).
  local exists = sol.game.exists(file)
  local game = sol.game.load(file)
  if not exists then
    -- This is a new savegame file.
    initial_game:initialise_new_savegame(game)
  end

	game:register_event("on_started", function()
		tone = tone_manager:create(game)
		condition_manager:initialise(game)
		map_name:initialise(game)
		field_music(game)
    effect_manager:set_effect(game, fsa)
    game:set_value("mode", "fsa")
		game:set_world_rain_mode("outside_world", nil)
		game:set_world_snow_mode("outside_world", nil)
		game:set_time_flow(1000)
    print("Main quest step start:"..game:get_value("main_quest_step"))
	end)

	game:register_event("on_finished", function()
    print("Main quest step finish:"..game:get_value("main_quest_step"))
	end)

	game:register_event("on_map_changed", function()
		tone:on_map_changed()
	end)

  function game:get_player_name()

    local name = self:get_value("player_name")
    local hero_is_thief = game:get_value("hero_is_thief")
    if hero_is_thief then
      name = sol.language.get_string("game.thief")
    end
    return name
  end

  function game:set_player_name(player_name)
    self:set_value("player_name", player_name)
  end

  -- Returns whether the current map is in the inside world.
  function game:is_in_inside_world()
    return game:get_map():get_world() == "inside_world"
  end

  -- Returns whether the current map is in the outside world.
  function game:is_in_outside_world()
    return game:get_map():get_world() == "outside_world"
  end

  -- Returns whether the current map is in a dungeon.
  function game:is_in_dungeon()
    return game:get_dungeon() ~= nil
  end

  -- Returns whether something is consuming magic continuously.
  function game:is_magic_decreasing()
    return game.magic_decreasing or false
  end

  -- Sets whether something is consuming magic continuously.
  function game:set_magic_decreasing(magic_decreasing)
    game.magic_decreasing = magic_decreasing
  end

	local alpha_warn = sol.surface.create("hud/version.png")


  return game
end


  -- Show a dialog when the player cannot lift them.
  local destructible_meta = sol.main.get_metatable("destructible")
  -- destructible_meta represents the shared behavior of all destructible objects.


  function destructible_meta:on_looked()

    -- Here, self is the destructible object.
    local game = self:get_game()
    local sprite = self:get_sprite()
    if self:get_can_be_cut() == false then
      if not game:has_ability("lift") then
        game:start_dialog("_cannot_lift_too_heavy");
      else
        game:start_dialog("_cannot_lift_still_too_heavy");
      end
    end
  end


return game_manager

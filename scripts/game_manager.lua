-- Script that creates a game ready to be played.

-- Usage:
-- local game_manager = require("scripts/game_manager")
-- local game = game_manager:create("savegame_file_name")
-- game:start()
require("scripts/multi_events")
local initial_game = require("scripts/initial_game")
local game_manager = {}
local tone_manager = require("scripts/maps/daytime_manager")
local condition_manager = require("scripts/hero_condition")
local map_name = require("scripts/hud/map_name")
--local field_music = require("scripts/maps/hyrule_field")
local effect_manager = require('scripts/maps/effect_manager')
local gb = require('scripts/maps/gb_effect')
local fsa = require('scripts/maps/fsa_effect')
time_flow = 500

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
    
    local version_check_menu = {}
    game:register_event("on_started", function()
      
		tone = tone_manager:create(game)
		condition_manager:initialise(game)
		map_name:initialise(game)
    effect_manager:set_effect(game, fsa)
    game:set_value("mode", "fsa")
		game:set_world_rain_mode("outside_world", nil)
		game:set_world_snow_mode("outside_world", nil)
		game:set_time_flow(time_flow)
    print("Main quest step start:"..game:get_value("main_quest_step"))
		sol.menu.start(game, version_check_menu, true)

    local ceiling_drop_manager = require("scripts/maps/ceiling_drop_manager")
    for _, entity_type in pairs({"hero", "pickable", "block"}) do
      ceiling_drop_manager:create(entity_type)
    end


	end)
  
	game:register_event("on_finished", function()
    print("Main quest step finish:"..game:get_value("main_quest_step"))
    
	end)
  
	game:register_event("on_map_changed", function()
		tone:on_map_changed()
	end)
  
  game:register_event("on_world_changed", function()
    local map = game:get_map()
    if not game.teleport_in_progress then -- play custom transition at game startup
    if (game:get_value("time_saved") < 1766346617) then
      game:check_variables()
    end
      game:set_suspended(true)
      local opening_transition = require("scripts/gfx_effects/radial_fade_out")
      opening_transition.start_effect(map:get_camera():get_surface(), game, "out", nil, function()
        game:set_suspended(false)
        if map.do_after_transition then
          map.do_after_transition()
        end
      end)
    end
  end)
    
  function game:check_variables()
    game:start_dialog("scripts.menus.version_checker.update_question", function(answer)
      if answer == 1 then
        game:assign_variables("dungeon_2_b2_24_pool_full", true, "dungeon_2_water_level", "high")
        game:assign_variables("dungeon_2_b2_24_pool_full",false, "dungeon_2_water_level",  "low")
        game:assign_variables("possession_tunic", 1, "possession_tunic_green", 1)
        game:assign_variables("possession_tunic", 2, "possession_tunic_blue",1 )
        game:assign_variables("possession_tunic", 3, "possession_tunic_red", 1)
        game:assign_variables("possession_tunic", 4, "possession_tunic_time", 1)
        game:convert_variables("treasure_d1","dungeon_1_treasure")
        game:convert_variables("dungeon_2_yellow_key","dungeon_2_silver_key")
        game:convert_variables("dungeon_3_yellow_key","dungeon_3_silver_key")
        game:convert_variables("dungeon_10_yellow_key","dungeon_10_silver_key")
        game:convert_variables("possession_golden_leaf_counter","possession_golden_leaf_counter")
        game:convert_variables("possession_goron_amber_counter","possession_goron_amber")
        game:convert_variables("amount_goron_amber_counter","amount_goron_amber")
        game:convert_variables("possession_monster_claw_counter","possession_monster_claw")
        game:convert_variables("amount_monster_claw_counter","amount_monster_claw")
        game:convert_variables("possession_monster_horn_counter","possession_monster_horn")
        game:convert_variables("amount_monster_horn_counter","amount_monster_horn")
        game:convert_variables("possession_monster_gut_counter","possession_monster_gut")
        game:convert_variables("amount_monster_gut_counter","amount_monster_gut")
        game:convert_variables("possession_monster_tail_counter","possession_monster_tail")
        game:convert_variables("amount_monster_tail_counter","amount_monster_tail")
        game:convert_variables("possession_photo_counter","possession_photo_counter")
        game:convert_variables("amount_photo_counter","amount_photo_counter")
        game:convert_variables("possession_seashell_counter","possession_seashell_counter")
        game:convert_variables("amount_seashell_counter","amount_seashell_counter")
        game:convert_variables("possession_slim_key","possession_slim_key")
        game:convert_variables("possession_tail_key","possession_tail_key")
        game:convert_variables("possession_butter","possession_butter")
        game:convert_variables("possession_green_tunic","possession_tunic_green")
        game:convert_variables("possession_blue_tunic","possession_tunic_blue")
        game:convert_variables("possession_red_tunic","possession_tunic_red")
        game:convert_variables("possession_hero_shield","possession_shield_hero")
        game:convert_variables("possession_hylia_shield","possession_shield_hylia")
        game:convert_variables("possession_mirror_shield","possession_shield_mirror")
        game:convert_variables("possession_time_tunic","possession_tunic_time")
        game:convert_variables("dungeon_5_1f_20_chest_smal_key","dungeon_5_1f_20_chest_small_key")
        game:convert_variables("dungeons_1_final_door","dungeons_1_final_door")
        game:convert_variables("dungeon_1_door_small_key","dungeon_1_0f_door_28_33")
        game:convert_variables("door_d1_23_n1","dungeon_1_0f_door_18_23")
        game:convert_variables("d9_2f_b4_lynel","d9_2f_b4_lynel")
        game:convert_variables("d9_2f_b4_sm","d9_2f_b4_sm")
        game:convert_variables("chest_a7_1","outside_parapa_town_chest_rupees")
        game:convert_variables("ravios_shop_healing_wand","inside_ravios_shop_healing_wand")
        game:convert_variables("ravios_shop_bottle","inside_ravios_shop_bottle")
        --21/12/2025
        game:convert_variables("possession_light_rod","possession_rod_light")
        game:convert_variables("possession_wind_rod","possession_rod_wind")
        game:convert_variables("possession_thunder_rod","possession_rod_thunder")
        game:convert_variables("possession_darkness_rod","possession_rod_darkness")
        game:convert_variables("possession_ice_rod","possession_rod_ice")
        game:convert_variables("possession_fire_rod","possession_rod_fire")
      else sol.main.reset()
      end
    end)
  end
  
  function game:convert_variables(old_variable, new_variable)
    if game:get_value(old_variable) ~= nil then
      game:set_value(new_variable, game:get_value(old_variable))
      print("Setting the variable "..new_variable)
      game:set_value(old_variable, nil)
      print("Clearing the variable " .. old_variable)
    end
  end

  function game:assign_variables(old_variable, new_variable, old_value, new_value)
    if game:get_value(old_variable) == old_value then
      game:set_value(new_variable, new_value)
      print("Setting the variable "..new_variable)
      game:set_value(old_variable, nil)
      print("Clearing the variable " .. old_variable)
    end
  end

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

  return game
end

return game_manager

-- Lua script of map out/f5.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local field_music_manager = require("scripts/maps/field_music_manager")
local num_dialogue = 0


map:register_event("on_started", function()
	game:show_map_name("hyrule_town")
	map:set_digging_allowed(true)
  npc_impa:set_enabled(false)
  if game:is_step_done("sahasrahla_lost_woods_map") then
    town_gate:set_enabled(false)
  end
  for npc in map:get_entities("npc_soldier_") do
    if game:is_step_done("lamp_obtained") then
      npc:set_enabled(false)
    else npc:set_enabled(true)
    end
  end
  if game:is_step_last("game_started") then
    npc_impa:set_enabled(true)
    npc_impa:set_visible(false)
  else npc_impa:set_enabled(false)
  end
  
--[[  for npc in map:get_entities("") do
    local npc_movement = sol.movement.create("random_path")
    npc_movement:set_speed(64)
    npc_movement:start(npc)
  end--]]
end)


for npc in map:get_entities("npc_soldier_") do
  npc:register_event("on_interaction", function()
    if num_dialogue == 0 then
      game:start_dialog("maps.out.hyrule_town.soldiers.no_lamp")
      num_dialogue = 1
    elseif num_dialogue == 1 then
      game:start_dialog("maps.out.hyrule_town.soldiers.tip_item")
      num_dialogue = 2
    elseif num_dialogue == 2 then
      game:start_dialog("maps.out.hyrule_town.soldiers.tip_pause")
      num_dialogue = 3
    elseif num_dialogue == 3 then
      game:start_dialog("maps.out.hyrule_town.soldiers.tip_speak")
      num_dialogue = 0
    end
  end)
end


sensor_ocarina_cutscene:register_event("on_activated", function()
  if game:is_step_last("game_started") then
    npc_impa:set_enabled(true)
    npc_impa:set_visible(true)
    map:set_cinematic_mode(true, options)
    hero:freeze()
    hero:set_direction(1)
    audio_manager:play_music("cutscenes/cutscene_zelda")
    local impa_movement_to_position = sol.movement.create("target")
    impa_movement_to_position:set_target(impa_position)
    impa_movement_to_position:set_ignore_obstacles(true)
    impa_movement_to_position:set_ignore_suspend(true)
    impa_movement_to_position:set_speed(100)
    impa_movement_to_position:start(npc_impa, function()
      ocarina_dialog()
    end)
  end
end)

function ocarina_dialog()
  game:start_dialog("maps.out.hyrule_town.impa.sahasrahla", game:get_player_name(), function(answer)
    if answer == 1 then
      ocarina_dialog()
    elseif answer == 2 then
      game:start_dialog("maps.out.hyrule_town.impa.song_learnt", function()
        hero:start_treasure("song_10_zelda")
        game:set_step_done("ocarina_obtained")
        local impa_movement_leave = sol.movement.create("target")
        impa_movement_leave:set_target(640, 208)
        impa_movement_leave:set_ignore_obstacles(true)
        impa_movement_leave:set_ignore_suspend(true)
        impa_movement_leave:set_speed(100)
        impa_movement_leave:start(npc_impa, function()
          map:set_cinematic_mode(false, options)
          npc_impa:set_enabled(false)
          audio_manager:play_music_fade(map, map:get_music())
          hero:unfreeze()
        end)
      end) 
    end
  end)
end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

open_house_door_castle_sensor:register_event("on_activated", function()
  if hero:get_direction() == 1 and door_castle_1:is_enabled() and door_castle_2:is_enabled() then
    door_castle_1:set_enabled(false)
    door_castle_2:set_enabled(false)
    sol.audio.play_sound("door_open")
  end
end)

for npc in map:get_entities("npc_laundry_") do
  npc:register_event("on_interaction", function()
    if game:is_step_last("ocarina_obtained") then
      game:start_dialog("maps.out.hyrule_town.laundry_pool.no_magic_bar")
    elseif game:is_step_last("agahnim_met") then
      game:start_dialog("maps.out.hyrule_town.laundry_pool.soldiers")
    end
  end)
end

npc_drunk_man:register_event("on_interaction", function()
  if game:is_step_last("ocarina_obtained") then
    game:start_dialog("maps.out.hyrule_town.drunk_man.no_lamp")
  elseif game:is_step_last("lamp_obtained") then
    game:start_dialog("maps.out.hyrule_town.drunk_man.no_sword")
  else game:start_dialog("maps.out.hyrule_town.drunk_man.sleeping")
  end
end)

npc_fisher:register_event("on_interaction", function()
  if game:is_step_last("ocarina_obtained") then
    game:start_dialog("maps.out.hyrule_town.fisher.welcome_no_lamp")
  elseif game:is_step_last("lamp_obtained") then
    game:start_dialog("maps.out.hyrule_town.fisher.welcome_no_sword")
  else game:start_dialog("maps.out.hyrule_town.fisher.welcome")
  end
end)

--On butter quest npc interaction
function npc_4:on_interaction()
--Get if player have begun this quest
  if game:get_value("quest_butter", 0) then
    game:start_dialog("quest.butter.need_butter", function(answer)
      if answer == 2 then
        game:start_dialog("quest.butter.yes")
        game:set_value("quest_butter", 1)
      else
        game:start_dialog("quest.butter.no")
      end
    end)
  end
end 
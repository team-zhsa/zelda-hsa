-- Lua script of item "flippers".
-- This script is executed only once for the whole game.

-- Variables
local item = ...
local game = item:get_game()

-- Include scripts
require("scripts/multi_events")
require("scripts/states/diving")
local audio_manager = require("scripts/audio_manager")

-- Event called when the game is initialized.
function item:on_created()

  item:set_savegame_variable("possession_flippers")
  item.is_hero_diving = false
  item:set_sound_when_brandished(nil) 

end

function item:on_variant_changed(variant)

  item:get_game():set_ability("swim", variant)

end

function item:on_obtaining()

  audio_manager:play_sound("items/major_item")

end

-- Diving
game:register_event("on_command_pressed", function(game, command)

    local map = game:get_map()
    local hero = game:get_hero()
    if command == "attack" and hero:get_state() == "swimming" then
      hero:start_diving()
    end
    if command == "action" and hero:get_state()=="swimming" then
      --audio_manager:play_sound("hero/swim")
    end

  end)
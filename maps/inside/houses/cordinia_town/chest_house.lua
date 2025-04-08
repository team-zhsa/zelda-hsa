local map = ...
local game = map:get_game()
local audio_manager = require("scripts/audio_manager")
local playing = false
local won = false
local chest_open = nil
local rewards = {
  {item_name = "piece_of_heart", variant = 1, savegame_variable = "inside_cordinia_chest_game_piece_of_heart"},
  {item_name = "rupee", variant = 5},
  {item_name = "rupee", variant = 1},
  {item_name = "heart_triple", variant = 1},
  {item_name = "heart", variant = 1},
  {item_name = "arrow", variant = 1},
  {item_name = "arrow", variant = 2},
  {item_name = "arrow", variant = 3},
  {item_name = "bomb", variant = 1},
  {item_name = "bomb", variant = 2},
  {item_name = "bomb", variant = 3},
  {item_name = "magic_flask", variant = 1},
  {item_name = "magic_flask", variant = 2},
}

local function play_question_dialog_finished(answer)

  if answer == 1 then
    if game:get_money() >= 40 then
      game:remove_money(40)
      playing = true
			
      if chest_open ~= nil then
        chest_open:set_open(false)
      end
			audio_manager:play_music("inside/minigame_alttp")
      game:start_dialog("maps.houses.cordinia_town.chest_game.minigame_yes")

    else
      sol.audio.play_sound("common/wrong")
      game:start_dialog("_shop.not_enough_money")
    end
	else game:start_dialog("maps.houses.cordinia_town.chest_game.minigame_no")
  end
end

function npc_minigame:on_interaction()

  if playing and not won then
    game:start_dialog("maps.houses.cordinia_town.chest_game.minigame_already_playing")
  elseif not playing and won then
    game:start_dialog("maps.houses.cordinia_town.chest_game.minigame_finish")
  else
    game:start_dialog("maps.houses.cordinia_town.chest_game.minigame_welcome", play_question_dialog_finished)
  end
end

local function chest_empty(chest)

  hero:unfreeze()
  if playing then

    chest_open = chest

    -- choose a random treasure
    local index = math.random(#rewards)

    while rewards[index].savegame_variable ~= nil and
        game:get_value(rewards[index].savegame_variable) do
      -- don't give a saved reward twice (wooden key or piece of heart)
      index = math.random(#rewards)
    end

    hero:start_treasure(rewards[index].item_name, rewards[index].variant, rewards[index].savegame_variable)
    playing = false
    won = true
		audio_manager:play_music("inside/house")
  else
    sol.audio.play_sound("common/wrong")
    chest:set_open(false)
  end
end

for chest in map:get_entities("chest_") do
  chest.on_opened = chest_empty
end
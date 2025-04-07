local item = ...

local message_id = {
  "found_piece_of_heart.first",
  "found_piece_of_heart.second",
  "found_piece_of_heart.third",
  "found_piece_of_heart.fourth"
}

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_sound_when_brandished("heart_piece")
end

function item:on_obtained(variant)
  local game = self:get_game()
  local nb_pieces_of_heart = game:get_value("i1700") or 0
  game:start_dialog(message_id[nb_pieces_of_heart + 1], function()
    game:set_value("i1700", (nb_pieces_of_heart + 1) % 4)
    if nb_pieces_of_heart == 3 then
      game:add_max_life(4)
    end
    game:add_life(game:get_max_life())
    self:get_game():add_stamina(20)
  end)
end
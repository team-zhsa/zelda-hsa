local item = ...
local game = item:get_game()
local hero = game:get_hero()

-- Include scripts
local audio_manager = require("scripts/audio_manager")

local sound_timer

function item:on_created()

  item:set_savegame_variable("possession_bomb_counter")
  item:set_amount_savegame_variable("amount_bomb_counter")
  item:set_assignable(true)
end


function item:on_using()
  item:start_using()
  item:set_finished()
end


-- Called when the player uses the bombs of his inventory by pressing the corresponding item key.
function item:start_using()
--  debug_print "Single item bomb"
  if item:get_amount() == 0 then
    if sound_timer == nil then
      audio_manager:play_sound("misc/error")
      sound_timer = sol.timer.start(game, 500, function()
          sound_timer = nil
        end)
    end
  else
    local hero=item:get_game():get_hero()
    if not hero:is_jumping() and (hero.vspeed==0 or hero.vspeed==nil) then --not jumping
      item:remove_amount(1)
      local map = item:get_map()
      local x, y, layer = hero:get_position()
      local direction4 = hero:get_direction()
      local bomb = map:create_custom_entity({
        model = "bomb",
        sprite = "entities/bomb",
        direction = 0,
        x = x + (direction4 == 0 and 16 or direction4 == 2 and -16 or 0),
        y = y + (direction4 == 1 and -16 or direction4 == 3 and 16 or 0),
        layer = layer,
        width = 16,
        height = 16
      })
      audio_manager:play_sound("items/bomb")
    end
  end
  item:set_finished()

end

function item:create_bomb()
  local map = item:get_map()
  local hero = map:get_entity("hero")
  local x, y, layer = hero:get_position()
  local ox, oy=hero:get_sprite("tunic"):get_xy()
  local direction = hero:get_direction()
  if direction == 0 then
    x = x + 16
  elseif direction == 1 then
    y = y - 16
  elseif direction == 2 then
    x = x - 16
  elseif direction == 3 then
    y = y + 16
  end
  local bomb = map:create_bomb{
    x = x+ox,
    y = y+oy,
    layer = layer,
  }
  local sprite = bomb:get_sprite()
  function sprite:on_animation_changed(animation)
    if animation == "stopped_explosion_soon" then
      sol.timer.start(item, 1500, function()
          audio_manager:play_sound("environment/explosion")
        end)
    end
  end
  map.current_bombs = map.current_bombs or {}
  map.current_bombs[bomb] = true
  return bomb
end

function item:remove_bombs_on_map()

  local map = item:get_map()
  if map.current_bombs == nil then
    return
  end
  for bomb in pairs(map.current_bombs) do
    bomb:remove()
  end
  map.current_bombs = {}
end
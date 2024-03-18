-- Lua script of item "magic powders counter".
-- This script is executed only once for the whole game.

-- Variables
local item = ...
local game = item:get_game()

-- Include scripts
local audio_manager = require("scripts/audio_manager")

-- Event called when the game is initialized.
function item:on_created()

  self:set_savegame_variable("possession_magic_powder_counter")
  self:set_amount_savegame_variable("amount_magic_powder_counter")
  self:set_assignable(true)

end

-- Event called when the hero is using this item.
function item:on_using()
  if item:get_map():is_sideview() and item:get_game():get_hero().vspeed~=nil then
    return
  end
  local amount =   self:get_amount()
  amount = amount - 1
  if amount < 0 then
    audio_manager:play_sound("misc/error")
  else
    audio_manager:play_sound("items/magic_powder")
    local map = game:get_map()
    local hero = map:get_hero()
    local x,y,layer = hero:get_position()
    hero:freeze()
    hero:set_animation("magic_powder")
    self:set_amount(amount)
    item:create_powder()
    sol.timer.start(item, 400, function()
        if amount == 0 then
          self:set_variant(0)
        end
        hero:unfreeze()
      end)
  end
  self:set_finished()

end

-- Creates some fire on the map.
function item:create_powder()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()
  local dx, dy
  if direction == 0 then
    dx, dy = 18, -4
  elseif direction == 1 then
    dx, dy = 0, -24
  elseif direction == 2 then
    dx, dy = -20, -4
  else
    dx, dy = 0, 16
  end

  local x, y, layer = hero:get_position()
  local ox, oy=hero:get_sprite("tunic"):get_xy()
  local powder = map:create_custom_entity{
    model = "powder",
    x = x + dx + ox,
    y = y + dy + oy,
    layer = layer,
    width = 16,
    height = 16,
    direction = 0,
  }
  local powder_sprite = powder:get_sprite()
  powder_sprite:set_ignore_suspend(true)

end
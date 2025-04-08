-- Variables
local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local shadow
local sprite
local sprite_shadow

-- Include scripts
local audio_manager = require("scripts/audio_manager")
require("scripts/multi_events")

-- Event called when the custom entity is initialised.
entity:register_event("on_created", function()

  entity:set_layer_independent_collisions(true)
  local x, y, layer = entity:get_position()
  sprite = entity:get_sprite()
  sprite:set_animation("normal")
  shadow = map:create_custom_entity{
    x = x,
    y = y + 8,
    width = 16,
    height = 8,
    direction = 0,
    layer = 0 ,
    sprite ="entities/shadows/pickable_flying"
  }
  sprite_shadow = shadow:get_sprite()
  sprite_shadow:set_animation("normal")

  entity:add_collision_test("sprite", function(entity, other_entity)
    if other_entity:get_type()== "hero" and other_entity:is_jumping() then
      entity:on_picked()
      entity:remove()
    end
  end)

end)

entity:register_event("on_removed", function()
  
  shadow:remove()
  
end)

entity:register_event("on_picked", function()
  
  local sprite_name = entity:get_sprite():get_animation_set()
  -- Heart item.
  if sprite_name == "entities/items/heart_fly" then
    if game:get_life() == game:get_max_life() then
      audio_manager:play_sound("items/get_item")
    else
     game:add_life(12)
    end
  -- Bomb item.
  elseif sprite_name == "entities/items/bomb_fly" then
    bomb_counter = game:get_item("bomb_counter")
    if bomb_counter:get_amount() == bomb_counter:get_max_amount() then
      audio_manager:play_sound("items/get_item")
    else
      audio_manager:play_sound("items/get_item2")
      bomb_counter:add_amount(1)
    end
  -- Arrow item.
  elseif sprite_name == "entities/items/arrow_fly" then
    bow = game:get_item("bow")
    if bow:get_amount() == bow:get_max_amount() then
      audio_manager:play_sound("items/get_item")
    else
      audio_manager:play_sound("items/get_item2")
      bow:add_amount(1)
    end
  -- Rupee item.
  elseif sprite_name == "entities/items/rupee_fly" then
    if game:get_money() == game:get_max_money() then
      audio_manager:play_sound("items/get_item")
    else
      game:add_money(1)
    end
  elseif sprite_name == "entities/items/magic_powder_fly" then
    local powder_counter = game:get_item("magic_powder_counter")
    if powder_counter:get_variant() == 0 then
      powder_counter:set_variant(1)
    end
    if powder_counter:get_amount() == powder_counter:get_max_amount() then
      audio_manager:play_sound("items/get_item")
    else
      audio_manager:play_sound("items/get_item2")
      powder_counter:add_amount(10)
    end

  -- TDO: add more flying items here.

  end

end)
-- Configuration of the shop manager.
-- Feel free to change these values.

return {
  shovel = {
    price = 200,
    quantity = 1,
    placeholder = 1,
    variant = 1,
    sprite = "entities/items/item_shop_shovel",
    dialog_id = "shovel",
    buy_callback = function(map)
      local item = map:get_game():get_item("shovel")
      item:set_variant(1)
    end,  
    activation_condition = function(map)
      local item_shovel = map:get_game():get_item("shovel")
      local variant_shovel = item_shovel:get_variant()
      return variant_shovel == 0
    end
  },
  bombs = {
    price = 10,
    quantity = 10,
    placeholder = 4,
    variant = 1,
    sprite = "entities/items/item_shop_bomb",
    dialog_id = "bomb",
    buy_callback = function(map)
      local item_bombs_bag = map:get_game():get_item("bombs_bag")
      local item_bomb_counter = map:get_game():get_item("bomb_counter")
      if item_bombs_bag:get_variant() == 0 then
        item_bombs_bag:set_variant(1)
      end  
      item_bomb_counter:add_amount(10)
    end,  
    activation_condition = function(map)
      local item_shovel = map:get_game():get_item("shovel")
      local variant_shovel = item_shovel:get_variant()
      return variant_shovel > 0
    end
  },
  bow = {
    price = 980,
    quantity = 1,
    placeholder = 1,
    variant = 1,
    sprite = "entities/items/item_shop_bow",
    dialog_id = "bow",
    buy_callback = function(map)
      local item_quiver = map:get_game():get_item("quiver")
      item_quiver:set_variant(1)
      local item_bow = map:get_game():get_item("bow")
      item_bow:add_amount(10)
    end,  
    activation_condition = function(map)
      local item_quiver = map:get_game():get_item("quiver")
      local variant_quiver = item_quiver:get_variant()
      local item_shovel = map:get_game():get_item("shovel")
      local variant_shovel = item_shovel:get_variant()
      return variant_quiver == 0 and variant_shovel > 0
    end
  },
  arrow = {
    price = 10,
    quantity = 10,
    placeholder = 1,
    variant = 1,
    sprite = "entities/items/item_shop_arrow",
    dialog_id = "arrow",
    buy_callback = function(map)
      local item_bow = map:get_game():get_item("bow")
      item_bow:add_amount(10)
    end,  
    activation_condition = function(map)
      local item_quiver = map:get_game():get_item("quiver")
      local variant_quiver = item_quiver:get_variant()
      return variant_quiver > 0
    end  
  },
  heart = {
    price = 10,
    quantity = 3,
    placeholder = 2,
    variant = 1,
    sprite = "entities/items/item_shop_heart",
    dialog_id = "heart",
    buy_callback = function(map)
      local game = map:get_game()
      game:add_life(12)
    end, 
    activation_condition = function(map)
      return true
    end
  },
  shield = {
    price = 20,
    quantity = 1,
    placeholder = 3,
    variant = 1,
    sprite = "entities/items/item_shop_shield",
    dialog_id = "shield",
    buy_callback = function(map)
      local item = map:get_game():get_item("shield")
      item:set_variant(1)
    end, 
    activation_condition = function(map)
      return true
    end
  }
}
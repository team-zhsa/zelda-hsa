-- Configuration of the phone manager.
-- Feel free to change these values.

return {
  {
    message_key = 2,
    activation_condition = function(map)
      return
        map:get_game():get_value("first_phone_call")
    end
  },
  {
    message_key = 3,
    activation_condition = function(map)
      return map:get_game():is_step_done("dungeon_1_completed")
    end
  },
  {
    message_key = 4,
    activation_condition = function(map)
      return map:get_game():is_step_done("bowwow_joined")
    end
  },
  {
    message_key = 5,
    activation_condition = function(map)
      return map:get_game():is_step_done("dungeon_2_completed")
    end
  },
    {
    message_key = 6,
    activation_condition = function(map)
      local item = map:get_game():get_item("magnifying_lens")
      local variant = item:get_variant()
      return variant <= 3
    end
  },
  {
    message_key = 7,
    activation_condition = function(map)
      local item = map:get_game():get_item("magnifying_lens")
      local variant = item:get_variant()
      return map:get_game():is_step_done("dungeon_2_completed") and variant > 3
    end
  },
  {
    message_key = 8,
    activation_condition = function(map)
      return map:get_game():is_step_done("castle_bridge_built")
    end
  },
  {
    message_key = 9,
    activation_condition = function(map)
      return map:get_game():is_step_done("golden_leaved_returned")
    end
  },
  {
    message_key = 10,
    activation_condition = function(map)
      return map:get_game():is_step_done("dungeon_3_key_obtained")
    end
  },
    {
    message_key = 11,
    activation_condition = function(map)
      return map:get_game():is_step_done("dungeon_3_completed")
    end
  },
}
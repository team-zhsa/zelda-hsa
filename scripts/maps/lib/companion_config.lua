-- Configuration of the companion manager.
-- Feel free to change these values.
local audio_manager = require("scripts/audio_manager")

local excluded_maps_all_companions = {
  ["sideviews/mabe_village/sideview_1"] = true,
}

return {
  marin = {
    sprite = "npc/villagers/marin",
    activation_condition = function(map)
      if map:get_game():is_in_dungeon() then
        return false
      end
      if excluded_maps_all_companions[map:get_id()] then
        return false
      end
      return map:get_game():is_step_last("marin_joined")
    end
  },
  bowwow = {
    sprite = "npc/animals/bowwow",
    activation_condition = function(map)
      if excluded_maps_all_companions[map:get_id()] then
        return false
      end
      local excluded_maps = {
        ["houses/mabe_village/meow_meow_house"] = true
      }
      if excluded_maps[map:get_id()] then
        return false
      end
      if map:get_game():is_in_dungeon() then
        return false
      end
      return map:get_game():is_step_last("bowwow_joined") or map:get_game():is_step_last("dungeon_2_completed")
    end,
    repeated_behavior_delay = 2000,
    repeated_behavior = function(companion)
      if companion:get_state() == "eat_enemy" then
        companion:set_state("stopped")
        return false
      end
      local distance = 48
      local map = companion:get_map()
      local hero = map:get_hero()
      local x,y, layer = companion:get_position()
      local width = distance * 2
      local height = distance * 2
      local enemies = {}
      for entity in map:get_entities_in_rectangle(x - 24, y - 24 , width, height) do
        if entity:get_type() == "enemy" then
          enemies[#enemies + 1] = entity
        end
      end
      local index = math.random(1, #enemies)
      if enemies[index] ~= nil and not string.match(enemies[index]:get_breed(), "projectiles") and not enemies[index]:get_property("is_bowwow_friend") then
        companion:set_state("eat_enemy")
        -- Bowwow eat enemy
        local enemy = enemies[index]
        local direction4 = companion:get_direction4_to(enemy)
        companion:get_sprite():set_direction(direction4)
        companion:get_sprite():set_animation("angry")
        local movement_1 = sol.movement.create("target")
        movement_1:set_target(enemy)
        movement_1:set_speed(100)
        movement_1:set_ignore_obstacles(true)
        movement_1:start(companion)
        function movement_1:on_position_changed()
          if companion:get_distance(hero) > distance + 16 then
             companion:set_state("stopped")
            companion:get_sprite():set_animation("stopped")
          end
        end
        function movement_1:on_finished()
          enemy:set_pushed_back_when_hurt(false)
          enemy:set_visible(false)
          enemy:hurt(enemy:get_life())
          audio_manager:play_sound("enemies/enemy_die")
          companion:set_state("stopped")
          companion:get_sprite():set_animation("stopped")
        end
      end
    end
  },
  ghost = {
    sprite = "npc/villagers/ghost",
    activation_condition = function(map)
      if excluded_maps_all_companions[map:get_id()] then
        return false
      end
      if map:get_game():is_in_dungeon() then
        return false
      end
      return map:get_game():get_value("ghost_quest_step") == "ghost_joined"
        or map:get_game():get_value("ghost_quest_step") == "ghost_saw_his_house"
        or map:get_game():get_value("ghost_quest_step") == "ghost_house_visited"
        
    end,
    repeated_behavior_delay = 5000,
    repeated_behavior = function(companion)
      audio_manager:play_sound("misc/ghost")
    end
    
  },
  flying_rooster = {
    sprite = "npc/flying_rooster",
    activation_condition = function(map)
      if excluded_maps_all_companions[map:get_id()] then
        return false
      end
    end
  }
}
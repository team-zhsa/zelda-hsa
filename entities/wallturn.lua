-- Variables
local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local animation_launch = false
local sprite = entity:get_sprite()
local wallturn_teletransporter = map:get_entity(entity:get_name() .. "_teletransporter")

-- Include scripts
local audio_manager = require("scripts/audio_manager")
require("scripts/multi_events")

-- Event called when the custom entity is initialized.
entity:register_event("on_created", function()

  entity:set_traversable_by(false)
  entity:add_collision_test("touching", function(wall, hero)
    if animation_launch == false and hero:get_type() == "hero" then
      local door_prefix = entity:get_property("door_prefix")
      if door_prefix then
        map:set_doors_open(door_prefix, true)
      end
      animation_launch = true
      local x_t, y_t= wallturn_teletransporter:get_position()
      local map_id = map:get_id()
      hero:freeze() -- Freeze before changing the position to stop carried state properly if needed.
      hero:set_position(x_t, y_t)
      audio_manager:play_sound("misc/dungeon_one_way_door")
      sprite:set_animation("revolving_tunic_1", function()
        sprite:set_animation("stopped")
        entity:set_traversable_by(true)
        hero:set_animation("walking")
        hero:set_invincible(true)
        hero:set_direction(1)
        local movement = sol.movement.create("path")
        movement:set_path{2,2,2,2,2,2,2,2}
        movement:set_ignore_obstacles(true)
        movement:start(hero, function()
          hero:unfreeze()
          hero:set_invincible(false)
          entity:set_traversable_by(false)
          animation_launch = false
        end)
      end)
    end
  end)

end)

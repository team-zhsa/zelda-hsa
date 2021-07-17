-- Lua script of map inside/houses/kakariko/library.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  map:init_map_entities()
end

-- Initializes Entities based on player's progress
function map:init_map_entities()

    -- Secret book
  book_9:set_enabled(false)
  if game:get_value("get_secret_book") then
    book_9:set_enabled(true)
    book_secret:set_enabled(false)
  end
  collision_book:add_collision_test("facing", function(entity, other, entity_sprite, other_sprite)
    if other:get_type() == 'hero' and hero:get_state() == "custom" and hero:get_state_object():get_description()=="running"  and game:get_value("get_secret_book") == nil then
      sol.timer.start(map, 250, function()
        movement = sol.movement.create("jump")
        movement:set_speed(100)
        movement:set_distance(32)
        movement:set_direction8(6)
        movement:set_ignore_obstacles(true)
        movement:start(book_secret, function()
          audio_manager:play_sound("jump")
          game:set_value("get_secret_book", true)
          book_9:set_enabled(true)
          book_secret:set_enabled(false)
        end)
      end)
    end
  end)

end
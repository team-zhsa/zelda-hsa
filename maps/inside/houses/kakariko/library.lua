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

end

-- Discussion with Book
function map:open_book(book)
  game:start_dialog("maps.houses.kakarico_village.library.book_"..book..".question", function(answer)
    if answer == 1 then
      local entity = map:get_entity("book_"..book)
      local sprite = entity:get_sprite()
      sprite:set_animation("reading")
      game:start_dialog("maps.houses.kakarico_village.library.book_"..book..".content", function()
        sprite:set_animation("normal")
      end)
    end
  end)

end

-- NPCs events
function book_1_interaction:on_interaction()

  map:open_book(1)

end

function book_2_interaction:on_interaction()

  map:open_book(2)

end

function book_3_interaction:on_interaction()

  map:open_book(3)

end

function book_4_interaction:on_interaction()

  map:open_book(4)

end
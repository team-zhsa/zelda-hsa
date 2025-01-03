local item = ...

-- This script defines the behavior of pickable fairies present on the map.

function item:on_created()

  self:set_shadow(nil)
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
end

-- A fairy appears on the map: create its movement.
function item:on_pickable_created(pickable)

   -- Create a movement that goes into random directions,
   -- with a speed of 28 pixels per second.
  local movement = sol.movement.create("random")
  movement:set_speed(28)
  movement:set_ignore_obstacles(true)
  movement:set_max_distance(40)  -- Don't go too far.

  -- Put the fairy on the highest layer to show it above all walls.
  local map = pickable:get_map()
  local x, y = pickable:get_position()
  pickable:set_position(x, y, map:get_max_layer())
  pickable:set_layer_independent_collisions(true)  -- But detect collisions with lower layers anyway

  -- When the direction of the movement changes,
  -- update the direction of the fairy's sprite
  function pickable:on_movement_changed(movement)

    if pickable:get_followed_entity() == nil then

      local sprite = pickable:get_sprite()
      local angle = movement:get_angle()  -- Retrieve the current movement's direction.
      if angle >= math.pi / 2 and angle < 3 * math.pi / 2 then
        sprite:set_direction(1)  -- Look to the left.
      else
        sprite:set_direction(0)  -- Look to the right.
      end
    end
  end

  movement:start(pickable)
end

-- Obtaining a fairy.
function item:on_obtaining(variant, savegame_variable)

  if not self:get_game():has_bottle() then
    -- The player has no bottle: just restore 15 hearts.
    self:get_game():add_life(15 * 4)
  else
    -- The player has a bottle: start the dialog.
    self:get_game():start_dialog("_treasure.fairy", function(answer)

      if answer == "skipped" or answer == 2 then
        -- Restore 15 hearts.
        self:get_game():add_life(15 * 4)
        else
          -- Keep the fairy in a bottle.
          local first_empty_bottle = self:get_game():get_first_empty_bottle()
          if first_empty_bottle == nil then
            -- No empty bottle.
            self:get_game():start_dialog("_treasure.fairy.no_empty_bottle", function()
            self:get_game():add_life(15 * 4)
          end)
          sol.audio.play_sound("common/wrong")
        else
          -- Okay, empty bottle.
          first_empty_bottle:set_variant(6)
          sol.audio.play_sound("menus/danger")
        end
      end
    end)
  end
end
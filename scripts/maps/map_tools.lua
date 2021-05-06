local map_tools = {}

local audio_manager = require("scripts/audio_manager")

-----------------------
-- Visual effects.
-----------------------

-- Shake the screen
function map_tools.start_earthquake(shake_config)

  local map = sol.main.get_game():get_map()
  map:start_coroutine(function()
    local camera = map:get_camera()
    local timer_sound = sol.timer.start(map, 0, function()
      audio_manager:play_sound("misc/dungeon_shake")
      return 450
    end)
    timer_sound:set_suspended_with_map(false)
    wait_for(camera.shake, camera, shake_config)
    timer_sound:stop()
  end)
end

-- Start a chained explosion placed randomly around the entity coordinates.
function map_tools.start_chained_explosion_on_entity(entity, duration, max_distance, callback)

  local map = entity:get_map()
  local x, y, layer = entity:get_position()
  local main_time = sol.main.get_elapsed_time()
  
  audio_manager:play_sound("items/bomb_explode")

  local explosion = map:create_explosion(
      {name = "chained_explosion", x = x + math.random(-max_distance, max_distance), y = y + math.random(-max_distance, max_distance), layer = layer})
  if explosion ~= nil then -- Avoid Errors when closing the game while a chained explosion is running
    explosion:get_sprite():set_ignore_suspend(true)
    explosion:register_event("on_removed", function(explosion)
      local elapsed_time = sol.main.get_elapsed_time() - main_time
      if elapsed_time < duration then
        map_tools.start_chained_explosion_on_entity(entity, duration - elapsed_time, max_distance, callback)
      else
        callback()
      end
    end)
  end
end

-----------------------
-- Saving tools.
-----------------------

-- Save current entity position.
function map_tools.save_entity_position(entity)
  local game = sol.main.get_game()
  local world = entity:get_map():get_world()
  local entity_name = entity:get_name()
  local x, y, layer = entity:get_position()
  game:set_value(world .. "_" .. entity_name .. "_x", x)
  game:set_value(world .. "_" .. entity_name .. "_y", y)
  game:set_value(world .. "_" .. entity_name .. "_layer", layer)
end

-- Get saved position for the entity, or current position if nothing saved.
function map_tools.get_entity_saved_position(entity)
  local game = sol.main.get_game()
  local world = entity:get_map():get_world()
  local entity_name = entity:get_name()
  local x, y, layer = entity:get_position()
  x = game:get_value(world .. "_" .. entity_name .. "_x") or x
  y = game:get_value(world .. "_" .. entity_name .. "_y") or y
  layer = game:get_value(world .. "_" .. entity_name .. "_layer") or layer
  return x, y, layer
end

return map_tools
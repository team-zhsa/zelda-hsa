----------------------------------
--
-- Entity spawning new enemies periodically.
-- 
-- Methods : spawner:start()
--           spawner:stop()
-- Events :  spawner:on_enemy_spawned(enemy)
--
-- Usage : Place the entity on the map and set the "breed" custom property to the enemy breed to spawn.
-- Other custom properties have a default value that may be overridden.
--
----------------------------------

-- Global variables
local spawner = ...
local game = spawner:get_game()
local map = spawner:get_map()
local camera = map:get_camera()
local is_active = false
local is_spawning = false

-- Configuration variables
local breed = spawner:get_property("breed")
local minimum_time = spawner:get_property("minimum_time") or 2000
local maximum_time = spawner:get_property("maximum_time") or 4000
local treasure_name = spawner:get_property("treasure_name") or "random_with_charm"
local treasure_variant = spawner:get_property("treasure_variant") or 1
local autostart = spawner:get_property("autostart") == "true"

-- Return true if the spawner is active.
function spawner:is_active()
  return is_active
end

-- Make the spawner create a new enemy right now and start chain spawning.
function spawner:start()

  is_active = true
  spawner:spawn()
end

-- Make spawner stop creating new enemies.
function spawner:stop()
  is_active = false
end

-- Create the given enemy and schedule the next one.
function spawner:spawn()

  if not is_spawning then
    is_spawning = true
    local x, y, layer = spawner:get_position()
    local enemy = map:create_enemy({
      breed = breed,
      x = x,
      y = y,
      layer = layer,
      direction = direction or math.random(4) - 1,
      treasure_name = treasure_name,
      treasure_variant = treasure_variant
    })

    -- Call a spawner:on_enemy_spawned(enemy) event.
    if spawner.on_enemy_spawned then
      spawner:on_enemy_spawned(enemy)
    end

    sol.timer.start(spawner, math.random(minimum_time, maximum_time), function()
      is_spawning = false
      if is_active then
        spawner:spawn()
      end
    end)
  end
end

-- Initialization.
spawner:register_event("on_created", function(spawner)

  if autostart then
    spawner:start()
  end
end)
-- A flame that can hurt enemies.
-- It is meant to by created by the lamp and the wind rod.
local wind = ...
local sprite

local enemies_touched = { }

wind:set_size(8, 8)
wind:set_origin(4, 5)
sprite = wind:get_sprite() or wind:create_sprite("entities/whirlwind")
sprite:set_direction(wind:get_direction())

-- Remove the sprite if the animation finishes.
-- Use animation "flying" if you want it to persist.
function sprite:on_animation_finished()
  wind:remove()
end

-- Returns whether a destructible is a bush.
local function is_bush(destructible)

  local sprite = destructible:get_sprite()
  if sprite == nil then
    return false
  end

  local sprite_id = sprite:get_animation_set()
  return sprite_id == "entities/bush" or sprite_id:match("^entities/bushes/bush_")
end

local function bush_collision_test(wind, other)

  if other:get_type() ~= "destructible" then
    return false
  end

  if not is_bush(other) then
    return
  end

  -- Check if the wind box touches the one of the bush.
  -- To do this, we extend it of one pixel in all 4 directions.
  local x, y, width, height = wind:get_bounding_box()
  return other:overlaps(x - 1, y - 1, width + 2, height + 2)
end

-- Traversable rules.
wind:set_can_traverse("crystal", true)
wind:set_can_traverse("crystal_block", true)
wind:set_can_traverse("hero", true)
wind:set_can_traverse("jumper", true)
wind:set_can_traverse("stairs", false)
wind:set_can_traverse("stream", true)
wind:set_can_traverse("switch", true)
wind:set_can_traverse("teletransporter", true)
wind:set_can_traverse_ground("deep_water", true)
wind:set_can_traverse_ground("shallow_water", true)
wind:set_can_traverse_ground("hole", true)
wind:set_can_traverse_ground("lava", true)
wind:set_can_traverse_ground("prickles", true)
wind:set_can_traverse_ground("low_wall", true)
wind:set_can_traverse(true)
wind.apply_cliffs = true

-- Burn bushes.
wind:add_collision_test(bush_collision_test, function(wind, entity)

--[[  local map = wind:get_map()

  if entity:get_type() == "destructible" then
    if not is_bush(entity) then
      return
    end
    local bush = entity

    local bush_sprite = entity:get_sprite()
    if bush_sprite:get_animation() ~= "on_ground" then
      -- Possibly already being destroyed.
      return
    end

    wind:stop_movement()
    sprite:set_animation("stopped")
    sol.audio.play_sound("wind")

    -- TODO remove this when the engine provides a function destructible:destroy()
    local bush_sprite_id = bush_sprite:get_animation_set()
    local bush_x, bush_y, bush_layer = bush:get_position()
    local treasure = { bush:get_treasure() }
    if treasure ~= nil then
      local pickable = map:create_pickable({
        x = bush_x,
        y = bush_y,
        layer = bush_layer,
        treasure_name = treasure[1],
        treasure_variant = treasure[2],
        treasure_savegame_variable = treasure[3],
      })
    end

    sol.audio.play_sound(bush:get_destruction_sound())
    bush:remove()

    local bush_destroyed_sprite = wind:create_sprite(bush_sprite_id)
    local x, y = wind:get_position()
    bush_destroyed_sprite:set_xy(bush_x - x, bush_y - y)
    bush_destroyed_sprite:set_animation("destroy")
  end--]]
end)

-- Hurt enemies.
wind:add_collision_test("sprite", function(wind, entity)

  if entity:get_type() == "enemy" then
    local enemy = entity
    if enemies_touched[enemy] then
      -- If protected we don't want to play the sound repeatedly.
      return
    end
    enemies_touched[enemy] = true
    local reaction = enemy:get_wind_reaction(enemy_sprite)
    enemy:receive_attack_consequence("wind", reaction)

    sol.timer.start(wind, 200, function()
      wind:remove()
    end)
  end
  if entity:get_type() == "enemy" then
    local enemy = entity
    if enemies_touched[enemy] then
      -- If protected we don't want to play the sound repeatedly.
      return
    end
    enemies_touched[enemy] = true
    local reaction = enemy:get_wind_reaction(enemy_sprite)
    enemy:receive_attack_consequence("wind", reaction)

    sol.timer.start(wind, 200, function()
      wind:remove()
    end)
  end
end)

function wind:on_obstacle_reached()
  wind:remove()
end

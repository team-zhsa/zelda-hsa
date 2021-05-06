-- A flame that can hurt enemies.
-- It is meant to by created by the lamp and the ice rod.
local ice = ...
local sprite

local enemies_touched = { }

ice:set_size(8, 8)
ice:set_origin(4, 5)
sprite = ice:get_sprite() or ice:create_sprite("entities/ice")
sprite:set_direction(ice:get_direction())

-- Remove the sprite if the animation finishes.
-- Use animation "flying" if you want it to persist.
function sprite:on_animation_finished()
  ice:remove()
end

-- Returns whether a destructible is a bush.
local function is_bush(destructible)

  local sprite = destructible:get_sprite()
  if sprite == nil then
    return false
  end

  local sprite_id = sprite:get_animation_set()
  return sprite_id == "entities/bush" or sprite_id:match("^entities/Bushes/bush_")
end

local function bush_collision_test(ice, other)

  if other:get_type() ~= "destructible" then
    return false
  end

  if not is_bush(other) then
    return
  end

  -- Check if the ice box touches the one of the bush.
  -- To do this, we extend it of one pixel in all 4 directions.
  local x, y, width, height = ice:get_bounding_box()
  return other:overlaps(x - 1, y - 1, width + 2, height + 2)
end

-- Traversable rules.
ice:set_can_traverse("crystal", true)
ice:set_can_traverse("crystal_block", true)
ice:set_can_traverse("hero", true)
ice:set_can_traverse("jumper", true)
ice:set_can_traverse("stairs", false)
ice:set_can_traverse("stream", true)
ice:set_can_traverse("switch", true)
ice:set_can_traverse("teletransporter", true)
ice:set_can_traverse_ground("deep_water", true)
ice:set_can_traverse_ground("shallow_water", true)
ice:set_can_traverse_ground("hole", true)
ice:set_can_traverse_ground("lava", true)
ice:set_can_traverse_ground("prickles", true)
ice:set_can_traverse_ground("low_wall", true)
ice:set_can_traverse(true)
ice.apply_cliffs = true

-- Burn bushes.
ice:add_collision_test(bush_collision_test, function(ice, entity)

  local map = ice:get_map()

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

    ice:stop_movement()
    sprite:set_animation("stopped")
    sol.audio.play_sound("flame")

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

    local bush_destroyed_sprite = ice:create_sprite(bush_sprite_id)
    local x, y = ice :get_position()
    bush_destroyed_sprite:set_xy(bush_x - x, bush_y - y)
    bush_destroyed_sprite:set_animation("destroy")
  end
end)

-- Hurt enemies.
ice:add_collision_test("sprite", function(ice, entity)

  if entity:get_type() == "enemy" then
    local enemy = entity
    if enemies_touched[enemy] then
      -- If protected we don't want to play the sound repeatedly.
      return
    end
    enemies_touched[enemy] = true
    local reaction = enemy:get_ice_reaction(enemy_sprite)
    enemy:receive_attack_consequence("ice", reaction)

    sol.timer.start(ice, 200, function()
      ice:remove()
    end)
  end
  if entity:get_type() == "enemy" then
    local enemy = entity
    if enemies_touched[enemy] then
      -- If protected we don't want to play the sound repeatedly.
      return
    end
    enemies_touched[enemy] = true
    local reaction = enemy:get_ice_reaction(enemy_sprite)
    enemy:receive_attack_consequence("ice", reaction)

    sol.timer.start(ice, 200, function()
      ice:remove()
    end)
  end
end)

function ice:on_obstacle_reached()
  ice:remove()
end

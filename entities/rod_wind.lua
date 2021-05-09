
-- It is meant to by created by the wind rod.
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
  return sprite_id == "entities/bush" or sprite_id:match("^entities/Bushes/bush_")
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
wind:set_can_traverse_ground("grass", true)
wind:set_can_traverse_ground("prickles", true)
wind:set_can_traverse_ground("low_wall", true)
wind:set_can_traverse(true)
wind.apply_cliffs = true

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


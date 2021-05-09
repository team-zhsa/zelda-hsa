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

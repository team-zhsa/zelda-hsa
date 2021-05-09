-- A flame that can hurt enemies.
-- It is meant to by created by the lamp and the beam rod.
local beam = ...
local sprite

local enemies_touched = { }

beam:set_size(8, 8)
beam:set_origin(4, 5)
sprite = beam:get_sprite() or beam:create_sprite("hero/item/sword_beam")
sprite:set_direction(beam:get_direction())

-- Remove the sprite if the animation finishes.
-- Use animation "flying" if you want it to persist.
function sprite:on_animation_finished()
  beam:remove()
end

-- Returns whether a destructible is a bush.
local function is_solid(switch)

  local sprite = switch:get_sprite()
  if sprite == nil then
    return false
  end

  local sprite_id = sprite:get_animation_set()
  return sprite_id == "entities/Switches/solid_switch"
end

local function switch_collision_test(beam, other)

  if other:get_type() ~= "switch" then
    return false
  end

  if not is_solid(other) then
    return
  end

  -- Check if the beam box touches the one of the bush.
  -- To do this, we extend it of one pixel in all 4 directions.
  local x, y, width, height = beam:get_bounding_box()
  return other:overlaps(x - 1, y - 1, width + 2, height + 2)
end

-- Traversable rules.
beam:set_can_traverse("crystal", false)
beam:set_can_traverse("crystal_block", true)
beam:set_can_traverse("hero", true)
beam:set_can_traverse("jumper", true)
beam:set_can_traverse("stairs", false)
beam:set_can_traverse("stream", true)
beam:set_can_traverse("switch", true)
beam:set_can_traverse("teletransporter", true)
beam:set_can_traverse_ground("deep_water", true)
beam:set_can_traverse_ground("shallow_water", true)
beam:set_can_traverse_ground("hole", true)
beam:set_can_traverse_ground("lava", true)
beam:set_can_traverse_ground("prickles", true)
beam:set_can_traverse_ground("low_wall", true)
beam:set_can_traverse(true)
beam.apply_cliffs = true

-- Activate switches.
beam:add_collision_test(switch_collision_test, function(beam, entity)

  local map = beam:get_map()

  if entity:get_type() == "switch" then
    if not is_solid(entity) then
      return
    end
    local switch = entity

    local switch_sprite = entity:get_sprite()

    beam:stop_movement()
    sprite:set_animation("stopped")
		
  end
end)

-- Hurt enemies.
beam:add_collision_test("sprite", function(beam, entity)

  if entity:get_type() == "enemy" then
    local enemy = entity
    if enemies_touched[enemy] then
      -- If protected we don't want to play the sound repeatedly.
      return
    end
    enemies_touched[enemy] = true
    local reaction = enemy:get_beam_reaction(enemy_sprite)
    enemy:receive_attack_consequence("sword", reaction)

    sol.timer.start(beam, 200, function()
      beam:remove()
    end)
  end
  if entity:get_type() == "enemy" then
    local enemy = entity
    if enemies_touched[enemy] then
      -- If protected we don't want to play the sound repeatedly.
      return
    end
    enemies_touched[enemy] = true
    local reaction = enemy:get_beam_reaction(enemy_sprite)
    enemy:receive_attack_consequence("beam", 1)

    sol.timer.start(beam, 200, function()
      beam:remove()
    end)
  end
end)

function beam:on_obstacle_reached()
  beam:remove()
end

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
local function is_bush(destructible)

  local sprite = destructible:get_sprite()
  if sprite == nil then
    return false
  end

  local sprite_id = sprite:get_animation_set()
  return sprite_id == "entities/bush" or sprite_id:match("^entities/Bushes/bush_")
end

local function bush_collision_test(beam, other)

  if other:get_type() ~= "destructible" then
    return false
  end

  if not is_bush(other) then
    return
  end

  -- Check if the beam box touches the one of the bush.
  -- To do this, we extend it of one pixel in all 4 directions.
  local x, y, width, height = beam:get_bounding_box()
  return other:overlaps(x - 1, y - 1, width + 2, height + 2)
end

-- Traversable rules.
beam:set_can_traverse("crystal", true)
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

-- Burn bushes.
beam:add_collision_test(bush_collision_test, function(beam, entity)

--[[  local map = beam:get_map()

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

    beam:stop_movement()
    sprite:set_animation("stopped")
    sol.audio.play_sound("beam")

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

    local bush_destroyed_sprite = beam:create_sprite(bush_sprite_id)
    local x, y = beam:get_position()
    bush_destroyed_sprite:set_xy(bush_x - x, bush_y - y)
    bush_destroyed_sprite:set_animation("destroy")
  end--]]
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
    enemy:receive_attack_consequence("beam", reaction)

    sol.timer.start(beam, 200, function()
      beam:remove()
    end)
  end
end)

function beam:on_obstacle_reached()
  beam:remove()
end

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

-- Create an ice square at the specified place if there is deep water.
local function check_square(x, y)

  local map = ice:get_map()
  local _, _, layer = ice:get_position()

  -- Top-left corner of the candidate 16x16 square.
  x = math.floor(x / 16) * 16
  y = math.floor(y / 16) * 16

  -- Check that the four corners of the 16x16 square are on deep water.
  if map:get_ground(      x,      y, layer) ~= "lava" or
      map:get_ground(x + 15,      y, layer) ~= "lava" or
      map:get_ground(     x, y + 15, layer) ~= "lava" or
      map:get_ground(x + 15, y + 15, layer) ~= "lava" then
    return
  end

  local ice_path = map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    width = 16,
    height = 16,
    direction = 0,
  })
  ice_path:set_origin(0, 0)
  ice_path:set_modified_ground("ice")
  ice_path:create_sprite("entities/ice")
end

-- Create ice on two squares around the specified place if there is deep water.
local function check_two_squares(x, y)

  local movement = ice:get_movement()
  if movement == nil then
    return
  end
  local direction4 = movement:get_direction4()
  local horizontal = (direction4 % 2) == 0
  if horizontal then
    check_square(x, y - 8)
    check_square(x, y + 8)
  else
    check_square(x - 8, y)
    check_square(x + 8, y)
  end
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

function ice:go(angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_max_distance(104)
  movement:set_smooth(false)

  -- Compute the coordinate offset of each sprite.
  local x = math.cos(angle) * 16
  local y = -math.sin(angle) * 16
  sprites[1]:set_xy(2 * x, 2 * y)
  sprites[2]:set_xy(x, y)
  sprites[3]:set_xy(0, 0)

  sprites[1]:set_animation("1")
  sprites[2]:set_animation("2")
  sprites[3]:set_animation("3")

  movement:start(ice)

  -- The head of the beam will be used to determine candidate squares,
  -- so make sure we don't forget the first squares.
  local ice_x, ice_y = ice:get_position()
  local dx, dy = sprites[2]:get_xy()
  check_two_squares(ice_x + dx, ice_y + dy)
  dx, dy = sprites[1]:get_xy()
  check_two_squares(ice_x + dx, ice_y + dy)
end



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

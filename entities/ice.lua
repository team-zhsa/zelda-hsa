-- Variables
local ice = ...
local sprite
local is_active = true

-- Include scripts
local audio_manager = require("scripts/audio_manager")

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
  if not is_active or sprite == nil then
    return false
  end

  local sprite_id = sprite:get_animation_set()
  return sprite_id == "entities/destructibles/bush" or sprite_id:match("^entities/destructibles/bush_")
end

-- Returns whether a destructible is a bush.
local function is_ice_block(entity)

  local sprite = entity:get_sprite()
  if not is_active or sprite == nil then
    return false
  end
  local sprite_id = sprite:get_animation_set()
  return sprite_id == "entities/destructibles/block_ice"
end

local function bush_collision_test(ice, other)

  if other:get_type() ~= "destructible" and other:get_type() ~= "custom_entity" then
    return false
  end
  if not (is_bush(other) or is_ice_block(other)) then
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
ice:set_can_traverse("enemy", true)
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

-- Going off animation and remove
function ice:extinguish()

  is_active = false
  if sprite:get_animation() ~= "going_off" then
    ice:stop_movement()

    sprite:set_animation("going_off")
    function sprite:on_animation_finished()
      ice:remove()
    end
  end
end

-- Hurt enemies.
ice:add_collision_test("sprite", function(ice, entity, ice_sprite, entity_sprite)

  if is_active and entity:get_type() == "enemy" then
    local enemy = entity
    local reaction = enemy:get_ice_reaction(entity_sprite)

    -- Don't continue if ice has no effect on the enemy.
    if reaction == "protected" then
      ice:extinguish()
      return
    end
    if reaction == "ignored" then
      return
    end
    if reaction == nil or reaction == 0 then
      -- Freeze the enemy and make it unable to interact.
      local reactions = enemy:get_hero_weapons_reactions()
      sol.timer.stop_all(enemy)
      enemy:stop_movement()
      enemy:set_can_attack(false)

      -- Set the enemy's animation to frozen.
      local enemy_sprite = enemy:get_sprite()
      if enemy_sprite:has_animation("frozen") then
        enemy_sprite:set_animation("frozen")
        enemy:start_jumping(400, 8, math.pi / 2, 88, function()
          enemy:set_frozen(true)
        end)
      else
        local burning_sprite = enemy:create_sprite("entities/effects/flame", "burning")
        burning_sprite:set_xy(entity_sprite:get_xy())
        function burning_sprite:on_animation_finished()
          enemy:remove_sprite(burning_sprite)
        end
      end
    end
    --[[ Directly pass attack consequences if reaction is a function.
    if type(reaction) == "function" then
      ice:extinguish()
      enemy:receive_attack_consequence("ice", reaction)
      return
    end--]]



    -- Push it back.
    if enemy:is_pushed_back_when_hurt() then
      enemy:set_pushed_back_when_hurt(false) -- Avoid pushing back again.
      
      local enemy_x, enemy_y, _ = enemy:get_position()
      local enemy_sprite_x, enemy_sprite_y = entity_sprite:get_xy()
      local ice_x, ice_y, _ = ice:get_position()
      local movement = sol.movement.create("straight")
      movement:set_speed(256)
      movement:set_angle(math.atan2(ice_y - enemy_y - enemy_sprite_y, enemy_x - ice_x - enemy_sprite_x))
      movement:set_max_distance(32)
      movement:set_smooth(false)
      movement:start(enemy)

      -- Avoid enemy to restart before hurt.
      function movement:on_finished()
        enemy:stop_movement()
      end
      function movement:on_obstacle_reached()
        enemy:stop_movement()
      end
    end

    -- Remove the projectile and make the enemy burn.
    ice:extinguish()
    
  end
end)

function ice:on_obstacle_reached()
  ice:extinguish()
end

----------------------------------
--
-- Explosion allowing some additional properties.
--
-- Custom properties : damage_on_hero
--                     explosive_type_[1 to 10]
-- Events :            on_finished()
--
----------------------------------

local explosion = ...
local map = explosion:get_map()
local sprite = explosion:create_sprite("entities/explosion")
local audio_manager = require("scripts/audio_manager")

-- Configuration variables.
local explosed_entities = {}
local damage_on_hero = 4 --tonumber(explosion:get_property("damage_on_hero")) or 2
local explosive_types = {}
for i = 1, 10 do
  local type = explosion:get_property("explosive_type_" .. i)
  if not type then
    break
  end
  table.insert(explosive_types, type)
end
if #explosive_types == 0 then
  explosive_types = {"crystal", "destructible", "door", "enemy", "hero", "sensor"}
end

-- Return true if the entity is already exploded.
local function is_already_exploded(entity)

  for _, explosed_entity in pairs(explosed_entities) do 
    if entity == explosed_entity then
      return true
    end
  end
  table.insert(explosed_entities, entity)
  return false
end

-- Return true if the entity type can be exploded by this explosion.
local function is_entity_type_explosive(entity_type)

  for _, explosive_type in pairs(explosive_types) do
    if entity_type == explosive_type then
      return true
    end
  end
  return false
end

-- Interact with explosive entities on sprite collision.
explosion:add_collision_test("sprite", function(explosion, entity)

  -- Ensure to explode an entity only once by explosion.
  if is_already_exploded(entity) then
    return
  end

  -- Only try to explode the entity if this explosion can interact with its type.
  local type = entity:get_type()
  if not is_entity_type_explosive(type) then
    return
  end

  -- Explode the entity if possible.
  if type == "crystal" then
    map:set_crystal_state(not map:get_crystal_state())

  elseif type == "destructible" and entity:get_can_explode() then
    if entity:has_animation("destroy") then
      entity:get_sprite():set_animation("destroy", function()
        entity:remove()
      end)
    else
      entity:remove()
    end
    if entity.on_exploded then
      entity:on_exploded()
    end

  elseif type == "door" then
    if string.find(entity:get_sprite():get_animation_set(), "weak") or string.find(entity:get_sprite():get_animation_set(), "rock0") then -- Workaround : No fucking way to know if the door can be opened with an explosion, hardcode the name.
      entity:open()
      sol.audio.play_sound("common/secret_discover_minor")
    end

  elseif type == "enemy" then
    entity:receive_attack_consequence("explosion", entity:get_attack_consequence("explosion"))

  elseif type == "hero" and not entity:is_invincible() and not entity:is_blinking() then
    explosion:get_map():get_hero():start_hurt(explosion, 4)
  else -- Else interact with any other type of entity if the on_explosion() method is registered.
    if entity.on_explosion then
      entity:on_explosion()
    end
  end
end)

-- Interact with explosive entities on overlapping collision for entities that can't have sprite.
explosion:add_collision_test("overlapping", function(explosion, entity)

  -- Don't try to interact with entities that have a sprite.
  if entity:get_sprite() then
    return
  end

  -- Ensure to explode an entity only once by explosion.
  if is_already_exploded(entity) then
    return
  end

  -- Only try to explode the entity if this explosion can interact with its type.
  local type = entity:get_type()
  if not is_entity_type_explosive(type) then
    return
  end

  if type == "sensor" then 
    if entity.on_collision_explosion then
      entity:on_collision_explosion()
    end
  end
end)

-- Explode on created.
explosion:register_event("on_created", function(explosion)

  explosion:set_size(32, 32)
  explosion:set_origin(16, 16)
  sprite:set_animation("explosion", function()
    if explosion.on_finished then
      explosion:on_finished()
    end
    explosion:remove()
  end)
  --audio_manager:play_sound("items/bomb_explode")
end)
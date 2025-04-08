-- Initialise NPC behavior specific to this quest.
-- Variables
local npc_meta = sol.main.get_metatable("npc")

-- Include scripts
local audio_manager = require("scripts/audio_manager")

npc_meta:register_event("on_created", function(npc)
  
  local model = npc:get_property("model")
  if model ~= nil then
    require("scripts/npc/" .. model)(npc)
  end

  local sprite = npc:get_sprite()
  if sprite ~= nil then
    local sprite_id = sprite:get_animation_set()
    if sprite_id == "npc/specific/animals/chicken_white" then
      npc:random_walk()
    elseif sprite_id == "npc/specific/animals/doggy_brown" then
      npc:random_walk()
    end
  end

  local name = npc:get_name()
  if name == nil then
    return
  end

  if name:match("^random_walk_npc") then
    npc:random_walk()
  end

end)

npc_meta:register_event("on_interaction", function(npc)

  local sprite = npc:get_sprite()
  if sprite ~= nil then
    local sprite_id = sprite:get_animation_set()
    if sprite_id == "npc/specific/animals/chicken_white" then
      sol.audio.play_sound("alttp/cucco")
    elseif sprite_id == "npc/specific/animals/doggy_static"
      or sprite_id == "npc/specific/animals/doggy_brown" then
      sol.audio.play_sound("oot/dog")
    end
  end
end)

-- Makes the NPC randomly walk with the given optional speed.
function npc_meta:random_walk(speed)

  local movement = sol.movement.create("random_path")

  if speed ~= nil then
    movement:set_speed(speed)
  end

  movement:start(self)
end

-- Make signs hooks for the hookshot.
function npc_meta:is_hookable()

  local sprite = self:get_sprite()
  if sprite == nil then
    return false
  end

  return sprite:get_animation_set() == "entities/sign"
  
end

-- Create an exclamation symbol near npc
function npc_meta:create_symbol_exclamation(sound)
  
  local map = self:get_map()
  local x, y, layer = self:get_position()
  local sprite = self:get_sprite()
  y = y - 16
  if sprite:get_direction() == 2 then
    x = x + 16
  else
    x = x - 16
  end
  if sound then
    audio_manager:play_sound("menus/menu_select")
  end
  local symbol = map:create_custom_entity({
    sprite = "entities/symbols/exclamation",
    x = x,
    y = y,
    width = 16,
    height = 16,
    layer = layer + 1,
    direction = 0
  })

  return symbol
  
end

-- Create an interrogation symbol near npc
function npc_meta:create_symbol_interrogation(sound)
  
  local map = self:get_map()
  local x, y, layer = self:get_position()
  if sound then
    audio_manager:play_sound("menus/menu_select")
  end
  local symbol = map:create_custom_entity({
    sprite = "entities/symbols/interrogation",
    x = x - 16,
    y = y - 16,
    width = 16,
    height = 16,
    layer = layer + 1,
    direction = 0
  })

  return symbol
  
end

-- Create a collapse symbol near npc
function npc_meta:create_symbol_collapse(sound)
  
  local map = self:get_map()
  local x, y, layer = self:get_position()
  if sound then
    -- Todo create a custom sound
  end
  local symbol = map:create_custom_entity({
    sprite = "entities/symbols/collapse",
    x = x - 16,
    y = y - 16,
    width = 16,
    height = 16,
    layer = layer + 1,
    direction = 0
  })

  return symbol
  
end

return true

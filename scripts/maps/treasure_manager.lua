local treasure_manager = {}

-- Include scripts
local audio_manager = require("scripts/audio_manager")
local block_manager = require("scripts/maps/block_manager")
require("scripts/multi_events")

function treasure_manager:appear_chest(map, chest, sound)

  local chest = map:get_entity(chest)
  local game = map:get_game()
  local chest_width, chest_height = chest:get_size()
  local chest_sprite_width, _ = chest:get_sprite():get_size()
  if chest_sprite_width > chest_width then
    -- We need to create a wall so that the hero does not overlap the chest sprite.
    local chest_x, chest_y, layer = chest:get_position()
    local chest_origin_x, chest_origin_y = chest:get_origin()
    local wall = map:create_wall({
      layer = layer,
      x = chest_x - chest_origin_x - 8,
      y = chest_y - chest_origin_y,
      width = chest_sprite_width,
      height = chest_height,
      stops_hero = true,
      stops_npcs = true,
      stops_enemies = true,
      stops_blocks = true,
      stops_projectiles = true,
      enabled_at_start = false,
    })
    sol.timer.start(map, 0, function()
      if not map:get_hero():overlaps(wall) then
        wall:set_enabled(true)
        return false
      end
      return 10
    end)
  end
  chest:set_enabled(true)
  if sound ~= nil and sound ~= false then
    audio_manager:play_sound("common/chest_appear")
  end

end

function treasure_manager:disappear_chest(map, chest)
  
  local chest = map:get_entity(chest)
  chest:set_enabled(false)
  
end

function treasure_manager:appear_chest_if_savegame_exist(map, chest, savegame)
  
  local game = map:get_game()
  if savegame and game:get_value(savegame) then
    treasure_manager:appear_chest(map, chest, false)
  else
    treasure_manager:disappear_chest(map, chest)
  end
      
end

function treasure_manager:appear_chest_when_enemies_dead(map, enemy_prefix, chest)
    
  local function enemy_on_dead()
    local game = map:get_game()
    if not map:has_entities(enemy_prefix) then
       local chest_entity = map:get_entity(chest)
       local treasure, variant, savegame = chest_entity:get_treasure()
      if  not savegame or savegame and not game:get_value(savegame) then
         self:appear_chest(map, chest, true)
      end
    end
  end

  -- Setup for each existing enemy that matches the prefix and ones created in the future.
  for enemy in map:get_entities(enemy_prefix) do
    enemy:register_event("on_dead", enemy_on_dead)
  end
  map:register_event("on_enemy_created", function(map, enemy)
    if string.match(enemy:get_name() or "", enemy_prefix) then
      enemy:register_event("on_dead", enemy_on_dead)
    end
  end)

end

function treasure_manager:appear_chest_when_torches_lit(map, torches_prefix, chest)
  local function torch_on_lit(torch)
    for entity in map:get_entities(torches_prefix) do
      if not entity:is_lit() then
        return -- Remaining unlit torches.
      end
    end
    self:appear_chest(map, chest, true)
  end

  for torch in map:get_entities(torches_prefix) do
    torch:register_event("on_lit", torch_on_lit)
  end
end

function treasure_manager:appear_chest_when_blocks_moved(map, block_prefix, chest)
  block_manager:init_block_riddle(map, block_prefix, function()
      local game = map:get_game()
      local chest_entity = map:get_entity(chest)
      if chest_entity ~= nil then
        local treasure, variant, savegame = chest_entity:get_treasure()
        if not savegame or savegame and not game:get_value(savegame) then
          treasure_manager:appear_chest(map, chest, true)
        end
      end
    end)
end

function treasure_manager:appear_chest_when_flying_tiles_dead(map, enemy_prefix, chest)

  local function enemy_on_flying_tile_dead()
    local game = map:get_game()
    local chest_appear = true
    for enemy in map:get_entities(enemy_prefix) do
      if enemy.state ~= "destroying" then
        chest_appear = false
      end
    end
    if chest_appear then
      local chest_entity = map:get_entity(chest)
      if chest_entity ~= nil then
        local treasure, variant, savegame = chest_entity:get_treasure()
        if not savegame or savegame and not game:get_value(savegame) then
          self:appear_chest(map, chest, true)
        end
      end
    end
  end

  for enemy in map:get_entities(enemy_prefix) do
    enemy:register_event("on_flying_tile_dead", enemy_on_flying_tile_dead)
  end

end

function treasure_manager:appear_chest_when_hit_by_arrow(map, entity_name, chest)

  local function entity_on_hit_by_arrow(entity)
    self:appear_chest(map, chest, true)
  end

  local entity = map:get_entity(entity_name)
  entity:register_event("on_hit_by_arrow", entity_on_hit_by_arrow)
end

function treasure_manager:appear_pickable(map, pickable, sound)

  local pickable_entity = map:get_entity(pickable)
  if pickable_entity and not pickable_entity:is_enabled() then
    local game = map:get_game()
    map:start_coroutine(function()
        local options={
          entities_ignore_suspend={pickable,},
        }
        pickable_entity:set_enabled(true)
        pickable_entity:fall_from_ceiling(192, "jump", function()
          if sound ~= nil and sound ~= false then
            sol.audio.play_sound("common/secret_discover_minor")
          end
        end)
      end)
  end
end

function treasure_manager:disappear_pickable(map, pickable)
    
  local pickable = map:get_entity(pickable)
  if pickable then
    pickable:set_enabled(false)
  end

end

function treasure_manager:appear_pickable_if_savegame_exist(map, pickable, savegame)
  
  local game = map:get_game()
  if savegame and game:get_value(savegame) then
    treasure_manager:appear_pickable(map, pickable, false)
  else
    treasure_manager:disappear_pickable(map, pickable)
  end
      
end

function treasure_manager:appear_pickable_when_enemies_dead(map, enemy_prefix, pickable)

  local function enemy_on_dead()
    local game = map:get_game()
    if not map:has_entities(enemy_prefix) then
      local pickable_entity = map:get_entity(pickable)
      if pickable_entity ~= nil then
        local treasure, variant, savegame = pickable_entity:get_treasure()
        if not savegame or savegame and not game:get_value(savegame) then
          self:appear_pickable(map, pickable, true)
        end
      end
    end
  end

  -- Setup for each existing enemy that matches the prefix and ones created in the future.
  for enemy in map:get_entities(enemy_prefix) do
    enemy:register_event("on_dead", enemy_on_dead)
  end
  map:register_event("on_enemy_created", function(map, enemy)
    if string.match(enemy:get_name() or "", enemy_prefix) then
      enemy:register_event("on_dead", enemy_on_dead)
    end
  end)

end

function treasure_manager:appear_pickable_when_torches_lit(map, torches_prefix, pickable)
  local function torch_on_lit(torch)
    for entity in map:get_entities(torches_prefix) do
      if not entity:is_lit() then
        return -- Remaining unlit torches.
      end
    end
    self:appear_pickable(map, pickable, true)
  end

  for torch in map:get_entities(torches_prefix) do
    torch:register_event("on_lit", torch_on_lit)
  end
end

function treasure_manager:appear_pickable_when_blocks_moved(map, block_prefix, pickable)
  block_manager:init_block_riddle(map, block_prefix, function()
      local game = map:get_game()
      local pickable_entity = map:get_entity(pickable)
      if pickable_entity ~= nil then
        local treasure, variant, savegame = pickable_entity:get_treasure()
        if not savegame or savegame and not game:get_value(savegame) then
          treasure_manager:appear_pickable(map, pickable, true)
        end
      end
    end)
end

function treasure_manager:appear_pickable_when_flying_tiles_dead(map, enemy_prefix, pickable)

  local function enemy_on_flying_tile_dead()
    local game = map:get_game()
    local pickable_appear = true
    for enemy in map:get_entities(enemy_prefix) do
      if enemy.state ~= "destroying" then
        pickable_appear = false
      end
    end
    if pickable_appear then
      local pickable_entity = map:get_entity(pickable)
      if pickable_entity ~= nil then
        local treasure, variant, savegame = pickable_entity:get_treasure()
        if not savegame or savegame and not game:get_value(savegame) then
          self:appear_pickable(map, pickable, true)
        end
      end
    end
  end

  for enemy in map:get_entities(enemy_prefix) do
    enemy:register_event("on_flying_tile_dead", enemy_on_flying_tile_dead)
  end

end

function treasure_manager:appear_pickable_when_hit_by_arrow(map, entity_name, pickable)

  local function entity_on_hit_by_arrow(entity)
    self:appear_pickable(map, pickable, true)
  end

  local entity = map:get_entity(entity_name)
  entity:register_event("on_hit_by_arrow", entity_on_hit_by_arrow)
end

function treasure_manager:appear_heart_container_if_boss_dead(map)

    local game = map:get_game()
    local dungeon = game:get_dungeon_index()
    local savegame = "dungeon_" .. dungeon .. "_boss"
    if game:get_value(savegame) then
        heart_container:set_enabled(true)
        heart_container:fall_from_ceiling(192)
    end

end

function treasure_manager:get_instrument(map, dungeon)

  local game = map:get_game()
  local dungeon = game:get_dungeon_index()
  local hero = map:get_entity("hero")
  local x_hero,y_hero, layer_hero = hero:get_position()
  local timer
  hero:freeze()
  hero:set_animation("brandish")
  local instrument_entity = map:create_custom_entity({
      name = "brandish_sword",
      sprite = "entities/items",
      x = x_hero,
      y = y_hero - 24,
      width = 16,
      height = 16,
      layer = layer_hero,
      direction = 0
    })
  instrument_entity:get_sprite():set_animation("instrument_" .. dungeon)
  instrument_entity:get_sprite():set_direction(0)
  instrument_entity:get_sprite():set_ignore_suspend(true)
  sol.audio.stop_music()
  sol.audio.play_sound("instruments/instrument")
  timer = sol.timer.start(map, 7000, function() 
  end)
  timer:set_suspended_with_map(false)
  sol.timer.start(2000, function()
      game:start_dialog("_treasure.instrument_" .. dungeon ..".1", function()
        local remaining_time = timer:get_remaining_time()
        timer:stop()
        sol.timer.start(map, remaining_time, function()
          treasure_manager:play_instrument(map)
        end)
      end)
  end)
end

function treasure_manager:play_instrument(map)

     local game = map:get_game()
     local hero = map:get_entity("hero")
     local dungeon = game:get_dungeon_index()
     local opacity = 0
     local dungeon_infos = game:get_dungeon()
     sol.audio.play_sound("instruments/instrument_" .. dungeon)
      sol.timer.start(8000, function()
        local white_surface =  sol.surface.create(320, 256)
        white_surface:fill_color({255, 255, 255})
        function map:on_draw(dst_surface)
          white_surface:set_opacity(opacity)
          white_surface:draw(dst_surface)
          opacity = opacity + 1
          if opacity > 255 then
            opacity = 255
          end
        end
        sol.timer.start(3000, function()
            game:start_dialog("maps.dungeons.".. dungeon ..".indication", function()
              local map_id = dungeon_infos["teletransporter_end_dungeon"]["map_id"]
              local destination_name = dungeon_infos["teletransporter_end_dungeon"]["destination_name"]
              hero:teleport(map_id, destination_name, "fade")
            end)
        end)
      end)
end

return treasure_manager
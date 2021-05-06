require("scripts/multi_events")
local door_manager = {}



-- Open doors when all ennemis in the room are dead
function door_manager:open_when_enemies_dead(map, enemy_prefix, door_prefix, sound)


  local function enemy_on_dead()

    if sound == nil then
      sound = true
    end
    if not map:has_entities(enemy_prefix) then
        map:open_doors(door_prefix)
        if sound then
          sol.audio.play_sound("common/secret_discover_minor")
        end
   end
  end
   for enemy in map:get_entities(enemy_prefix) do
     --enemy.on_dead = enemy_on_dead
     enemy:register_event("on_dead", enemy_on_dead)
   end

end

-- Open doors when all flying tiles in the room are dead
function door_manager:open_when_flying_tiles_dead(map, enemy_prefix, door_prefix)

    local function enemy_on_flying_tile_dead()
     local open_door = true
     for enemy in map:get_entities(enemy_prefix) do
       if enemy.state ~= "destroying" then
        open_door = false
       end
     end
     if open_door then
        map:open_doors(door_prefix)
        sol.audio.play_sound("common/secret_discover_minor")
     end
  end
   for enemy in map:get_entities(enemy_prefix) do
     enemy.on_flying_tile_dead = enemy_on_flying_tile_dead
   end

end

-- Open doors when small boss is dead
function door_manager:open_if_small_boss_dead(map)

    local game = map:get_game()
    local dungeon = game:get_dungeon_index()
    local savegame = "dungeon_" .. dungeon .. "_small_boss"
    local door_prefix = "door_group_small_boss"
    if game:get_value(savegame) then
        map:set_doors_open(door_prefix, true)
    end

end

-- Open doors when boss is dead
function door_manager:open_if_boss_dead(map)

    local game = map:get_game()
    local dungeon = game:get_dungeon_index()
    local savegame = "dungeon_" .. dungeon .. "_boss"
    local door_prefix = "door_group_boss"
    if game:get_value(savegame) then
        map:set_doors_open(door_prefix, true)
    end

end

-- Open doors if block moved
function door_manager:open_if_block_moved(map, block_prefix, door_prefix)

      for block in map:get_entities(block_prefix) do
       if block.is_moved then
        map:open_doors(door_prefix)
       else
          map:close_doors(door_prefix)
       end
      end

end

-- Open doors when all blocks in the room are moved
function door_manager:open_when_blocks_moved(map, block_prefix, door_prefix)

      local remaining = map:get_entities_count(block_prefix)
      local function block_on_moved()
        remaining = remaining - 1
        if remaining == 0 then
            map:open_doors(door_prefix)
            sol.audio.play_sound("common/secret_discover_minor")
       end
      end
      for block in map:get_entities(block_prefix) do
        block.on_moved = block_on_moved
      end

end

-- Open doors when a switch in the room is activated
function door_manager:open_when_switch_activated(map, switch_prefix, door_prefix)

      local function switch_on_activated(switch)
        if not switch.is_activated then
          switch.is_activated = true
          map:open_doors(door_prefix)
          sol.audio.play_sound("common/secret_discover_minor")
        end
       end
      for switch in map:get_entities(switch_prefix) do
        switch.is_activated = false
        switch.on_activated = switch_on_activated
      end

end

-- Open doors when a block in the room are moved
function door_manager:open_when_block_moved(map, block_prefix, door_prefix)

      local function block_on_moved(block)
        if not block.is_moved then
          block.is_moved = true
          map:open_doors(door_prefix)
          sol.audio.play_sound("common/secret_discover_minor")
        end
       end
      for block in map:get_entities(block_prefix) do
        block.is_moved = false
        block.on_moved = block_on_moved
      end

end

-- Open doors when pot break
function door_manager:open_when_pot_break(map, door_prefix)

      local detect_entity = map:get_entity("detect_" .. door_prefix)
      detect_entity:add_collision_test("touching", function(entity_source, entity_dest)
        if entity_dest:get_type() == "carried_object" then
            map:open_doors(door_prefix)
            sol.audio.play_sound("common/secret_discover_minor")
        end
      end)

end

-- Destroy wall by explosion
function door_manager:destroy_wall(map, weak_wall_prefix)

  local game = map:get_game()
  local dungeon = game:get_dungeon_index()
  map:remove_entities(weak_wall_prefix)
  audio_manager:play_sound("misc/secret1")

end

function door_manager:open_hidden_staircase(map, entity_group, savegame_variable)
  local hero=map:get_hero()
  local game=map:get_game()
  map:start_coroutine(function()
      local options = {
        entities_ignore_suspend = {hero}
      }
      map:set_cinematic_mode(true, options)
      sol.audio.stop_music()
      wait(2000)
      local timer_sound = sol.timer.start(hero, 0, function()
          audio_manager:play_sound("misc/dungeon_shake")
          return 450
        end)
      timer_sound:set_suspended_with_map(false)
      local camera = map:get_camera()
      local shake_config = {
        count = 32,
        amplitude = 2,
        speed = 90
      }
      wait_for(camera.shake,camera,shake_config)
      timer_sound:stop()
      audio_manager:play_sound("items/bomb_explode")
      local x,y,layer = map:get_entity("placeholder_explosion_"..entity_group):get_position()
      map:create_explosion({
          x = x,
          y = y,
          layer = layer
        })
      map:create_explosion({
          x = x - 8,
          y = y - 8,
          layer = layer
        })
      map:create_explosion({
          x = x + 8,
          y = y + 8,
          layer = layer
        })
      for entity in map:get_entities(entity_group) do
        entity:remove()
      end
      wait(1000)
      audio_manager:play_sound("misc/secret1")
      game:play_dungeon_music()
      game:set_value(savegame_variable, true)
      map:set_cinematic_mode(false, options)
    end)
end

-- Open doors when all torches in the room are lit
function door_manager:open_when_torches_lit(map, torch_prefix, door_prefix)

  local remaining = 0
  local function torch_on_lit()
    local doors = map:get_entities(door_prefix)
    local is_closed = false
    for door in map:get_entities(door_prefix) do
      if door:is_closed() then
          is_closed = true
      end
    end
    if is_closed then
      remaining = remaining - 1
      if remaining == 0 then
        map:open_doors(door_prefix)
        sol.audio.play_sound("common/secret_discover_minor")
      end
    end
  end
  local has_torches = false
  for torch in map:get_entities(torch_prefix) do
    if not torch:is_lit() then
      remaining = remaining + 1
    end
    torch.on_lit = torch_on_lit
    has_torches = true
  end
  if has_torches and remaining == 0 then
    -- All torches of this door are already lit.
        sol.audio.play_sound("common/secret_discover_minor")
        map:open_doors(door_prefix)
  end
end

function door_manager:close_when_torches_unlit(map, torch_prefix, door_prefix)

  local remaining = 0
  local function torch_on_unlit()
    if door:is_closed() then
      remaining = remaining - 1
      if remaining == 0 then
        sol.audio.play_sound("secret")
        map:open_doors(door_prefix)
      end
    end
  end

  local has_torches = false
  for torch in map:get_entities(torch_prefix) do
    if torch:is_lit() then
      remaining = remaining + 1
    end
    torch.on_unlit = torch_on_unlit
    has_torches = true
  end
  if has_torches and remaining == 0 then
    -- All torches of this door are already unlit.
    map:set_doors_open(door_prefix, false)
  end
end


-- Close doors if ennemis in the room are not dead
function door_manager:close_if_enemies_not_dead(map, enemy_prefix, door_prefix)

   if map:has_entities(enemy_prefix) then
        map:close_doors(door_prefix)
  end
        
end


return door_manager
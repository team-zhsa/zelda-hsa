-- Variables
local travel_manager = {}
local positions_info = {
  [1] = {
        map_id = "out/b3_prairie",
        destination_name = "travel_destination",
        savegame = "travel_1"
  },
  [2] = {
        map_id = "out/a1_west_mt_tamaranch",
        destination_name = "travel_destination",
        savegame = "travel_2"
  },
  [3] = {
        map_id = "out/d1_east_mt_tamaranch",
        destination_name = "travel_destination",
        savegame = "travel_3"
  },
  [4] = {
        map_id = "out/d4_yarna_desert",
        destination_name = "travel_destination",
        savegame = "travel_4"
  }
}

-- Include scripts
local audio_manager = require("scripts/audio_manager")
local mode_7_manager = require("scripts/mode_7")

function travel_manager:init(map, from_id)
  
  local game = map:get_game()
  local savegame = positions_info[from_id]['savegame']
  if not game:get_value(savegame) then
    travel_manager:launch_cinematic(map, from_id)
  else
    travel_manager:launch_owl(map, from_id)
  end
  
end

function travel_manager:launch_cinematic(map, from_id)
    
  local game = map:get_game()
  local hero = map:get_hero()
  -- Transporter
  local transporter = map:get_entity('travel_transporter')
  -- Owl slab
  local owl_slab = map:get_entity('owl_slab')
  sol.main.start_coroutine(function()
    local options = {
      entities_ignore_suspend = {hero, transporter, owl_slab}
    }
    map:set_cinematic_mode(true, options)
    wait(2000)
    audio_manager:play_sound("misc/secret1")
    owl_slab:get_sprite():set_animation("activated")  
    travel_manager:launch_owl(map, from_id) 
  end)    
    
end 

function travel_manager:launch_owl(map, from_id)

  local game = map:get_game()
  local savegame = positions_info[from_id]['savegame']
  game:set_value(savegame, 1)
  local transporter = map:get_entity('travel_transporter')
  transporter:set_enabled(false)
  local i = from_id + 1
  if i > 4 then
    i = 1
  end
  while game:get_value(positions_info[i]['savegame']) == nil do
    i = i + 1
    if i > 4 then
      i = 1
    end
  end
  to_id = i
  if from_id ~= to_id then
    travel_manager:launch_owl_step_1(map, from_id, to_id)
  end

end


function travel_manager:launch_owl_step_1(map, from_id, to_id)

  local game = map:get_game()
  local hero = map:get_hero()
  -- Hero
  local x_hero,y_hero = hero:get_position()
  hero:get_sprite():set_direction(3)
  y_hero = y_hero - 16
  -- Transporter
  local transporter = map:get_entity('travel_transporter')
  local direction4 = transporter:get_direction4_to(hero)
  transporter:get_sprite():set_animation("walking")
  transporter:get_sprite():set_direction(direction4)
  local x_transporter,y_transporter, layer_transporter = transporter:get_position()
  transporter:set_enabled(true)
  -- Owl slab
  local owl_slab = map:get_entity('owl_slab')
  sol.main.start_coroutine(function() -- start a game coroutine since we will change map in between
    local options = {
      entities_ignore_suspend = {hero, transporter, owl_slab}
    }
    map:set_cinematic_mode(true, options)
    -- First step
    local movement1 = sol.movement.create("target")
    movement1:set_speed(150)
    movement1:set_ignore_obstacles(true)
    movement1:set_ignore_suspend(true)
    movement1:set_target(x_hero, y_hero)
    movement(movement1, transporter)
    hero:set_enabled(false)
    local hero_entity = map:create_custom_entity({
      name = "hero",
      sprite = "hero/tunic1",
      x = x_transporter,
      y = y_transporter + 16,
      width = 24,
      height = 24,
      layer = layer_transporter,
      direction = 0
    })
    -- Second step
    hero_entity:get_sprite():set_animation("flying")
    hero_entity:get_sprite():set_direction(3)
    local movement2 = sol.movement.create("straight")
    movement2:set_speed(100)
    movement2:set_angle(math.pi / 2)
    movement2:set_max_distance(128)
    movement2:set_ignore_obstacles(true)
    movement2:set_ignore_suspend(true)
    function movement2:on_position_changed()
      local x_transporter,y_transporter, layer_transporter = transporter:get_position()
      y_transporter = y_transporter + 16
      hero_entity:set_position(x_transporter, y_transporter, layer_transporter)
    end
    movement(movement2, transporter)
    -- Mode 7
    travel_manager:launch_owl_step_2(map, from_id, to_id)
    local new_map = wait_for(map.wait_on_next_map_opening_transition_finished, map)
    -- We are on new map, 
    travel_manager:launch_step_3(new_map, from_id, to_id)
  end, game) -- end start coroutine, game arg is important

end

function travel_manager:launch_owl_step_2(map, from_id, to_id)

  local game = map:get_game()
  local hero = map:get_hero()
  local map_id = positions_info[to_id]['map_id']
  local destination_name = positions_info[to_id]['destination_name']
  local entity = map:get_entity("travel_sensor")
  mode_7_manager:teleport(game, entity, map_id, destination_name)
  
end

function travel_manager:launch_step_3(map)

  local game = map:get_game()
  local hero = map:get_hero()
  print(map:get_id())
  -- Hero
  local x_hero,y_hero = hero:get_position()
  hero:get_sprite():set_direction(3)
  hero:set_enabled(false)
  -- Transporter
  local transporter = map:get_entity('travel_transporter')
  transporter:set_enabled(true)
  local direction4 = transporter:get_direction4_to(hero)
  transporter:get_sprite():set_animation("walking")
  transporter:get_sprite():set_direction(direction4)
  local x_transporter,y_transporter, layer_transporter = transporter:get_position()
  transporter:set_position(x_hero, y_hero - 128)
  -- Owl slab
  local owl_slab = map:get_entity('owl_slab')
  local hero_entity = map:create_custom_entity({
    name = "hero",
    sprite = "hero/tunic1",
    x = x_hero,
    y = y_transporter + 16,
    width = 24,
    height = 24,
    layer = layer_transporter,
    direction = 0
  })
  hero_entity:get_sprite():set_animation("flying")
  hero_entity:get_sprite():set_direction(3)
  local options = {
    entities_ignore_suspend = {hero, transporter, owl_slab}
  }
  map:set_cinematic_mode(true, options)
  sol.main.start_coroutine(function() -- start a game coroutine since we will change map in between
    -- First step
    local movement1 = sol.movement.create("target")
    movement1:set_speed(100)
    movement1:set_target(x_hero, y_hero - 16)
    movement1:set_ignore_obstacles(true)
    movement1:set_ignore_suspend(true)
    function movement1:on_position_changed()
      local x_transporter,y_transporter, layer_transporter = transporter:get_position()
      y_transporter = y_transporter + 16
      hero_entity:set_position(x_transporter, y_transporter, layer_transporter)
    end
    movement(movement1, transporter)
    hero:set_enabled(true)
    hero_entity:remove()
    -- Second step
    local direction4 = transporter:get_direction4_to(x_transporter, y_transporter)
    transporter:get_sprite():set_animation("walking")
    transporter:get_sprite():set_direction(direction4)
    local movement2 = sol.movement.create("target")
    movement2:set_speed(100)
    movement2:set_target(x_transporter, y_transporter)
    movement2:set_ignore_obstacles(true)
    movement2:set_ignore_suspend(true)
    movement(movement2, transporter)
    transporter:set_enabled(false)
    map:set_cinematic_mode(false)
  end)  

end


return travel_manager
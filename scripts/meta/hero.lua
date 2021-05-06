-- Initialize hero behavior specific to this quest.

require("scripts/multi_events")
local hero_meta = sol.main.get_metatable("hero")
local fall_manager = require("scripts/maps/ceiling_drop_manager.lua")
local audio_manager = require("scripts/audio_manager.lua")
fall_manager:create("hero")

hero_meta:register_event("on_state_changed", function(hero)
  local current_state = hero:get_state()
  if hero.previous_state == "carrying" then
    hero:notify_object_thrown()
  end
  hero.previous_state = current_state
end)
hero_meta:register_event("notify_object_thrown", function() end)

hero_meta:register_event("on_position_changed", function(hero)

  local game = hero:get_game()
  local map = game:get_map()
  local dungeon = game:get_dungeon()
  local x, y = hero:get_center_position()
  if dungeon == nil then
    local world = map:get_world()
    local square_x = 0
    local square_y = 0
    local square_mini_x = 0
    local square_mini_y = 0
    local square_total_x = 0
    local square_total_y = 0
    local map_max_x = 3840
    local map_max_y = 3072
    if world == "outside_world" then
      local map_x, map_y = map:get_location()
      local map_size_x, map_size_y = map:get_size()
      square_x = math.floor((map_x + 960) / (960) - 1)
      square_y = math.floor((map_y + 768) / (768) - 1)
      if x == 0 then
        square_min_x = 0
      else
        square_min_x = math.floor((x+240)/(240)-1)
      end
      if y == 0 then
        square_min_y = 0
      else
        square_min_y = math.floor((y+192)/(192)-1)
      end
      square_total_x = (4*square_x)+square_min_x
      square_total_y = (4*square_y)+square_min_y
      --game:set_value("map_discovering_" .. square_total_x .. "_" .. square_total_y, true)
      --game:set_value("map_hero_position_x", square_total_x)
      --game:set_value("map_hero_position_y", square_total_y)
    end
  else
    local map_width, map_height = map:get_size()
    local room_width, room_height = 320, 240  -- TODO don't hardcode these numbers
    local num_columns = math.floor(map_width / room_width)
    local column = math.floor(x / room_width)
    local row = math.floor(y / room_height)
    local room = row * num_columns + column + 1
    local room_old = game:get_value("room")
   --[[ if game:has_dungeon_compass() and room_old ~= room and game:is_secret_room(nil, nil, room)  and game:is_secret_signal_room(nil, nil, room) then
      local timer = sol.timer.start(map, 500, function()
        sol.audio.play_sound("compass_signal")
      end)
    end--]]
    game:set_value("room", room)
    game:set_explored_dungeon_room(nil, nil, room)
    
  end
end)

hero_meta:register_event("on_state_changed", function(hero , state)

  local game = hero:get_game()

  -- Avoid to lose any life when drowning.
  if state == "back to solid ground" then
    local ground = hero:get_ground_below()
    if ground == "deep_water" then
      game:add_life(0)
    end
  end
end)


function hero_meta.is_running(hero)
  return hero.running
end

-- Return true if the hero is walking.
function hero_meta:is_walking()

  local m = self:get_movement()
  return m and m.get_speed and m:get_speed() > 0
end

-- Set fixed stopped/walking animations for the hero (or nil to disable them).
function hero_meta:set_fixed_animations(new_stopped_animation, new_walking_animation)

  fixed_stopped_animation = new_stopped_animation
  fixed_walking_animation = new_walking_animation
  -- Initialize fixed animations if necessary.
  local state = self:get_state()
  if state == "free" then
    if self:is_walking() then self:set_animation(fixed_walking_animation or "walking")
    else self:set_animation(fixed_stopped_animation or "stopped") end
  end
end

function hero_meta:on_obstacle_reached()
	local game = self:get_game()
  local map = game:get_map()
	if self:get_state() == "running" then
		  local camera = map:get_camera()
  		if not camera:is_shaking() then
    		camera:dynamic_shake({count = 50, amplitude = 2, speed = 90, entity=hero})
  		end
	end
end

function hero_meta.show_ground_effect(hero, id)

  local map = hero:get_map()
  local x,y, layer = hero:get_position()
  local ground_effect = map:create_custom_entity({
      name = "ground_effect",
      sprite = "entities/ground_effects/"..id,
      x = x,
      y = y ,
      width = 16,
      height = 16,
      layer = layer,
      direction = 0
    })
  local sprite = ground_effect:get_sprite()
  function sprite:on_animation_finished()
    ground_effect:remove()
  end

end

local function find_valid_ground(hero)

  local ground
  local x,y=hero:get_position()
  local map=hero:get_map()

  for layer=hero:get_layer(), map:get_min_layer(), -1 do
    ground=map:get_ground(x,y,layer)
    if ground~="empty" then
      return ground
    end
  end

  return "empty"
end

function hero_meta.play_ground_effect(hero)
  --print "About to play a ground effect"
  local map=hero:get_map()
  local ground=find_valid_ground(hero)
  --print ("ground: "..ground)
  local x,y=hero:get_position()

  if ground=="shallow_water" then
    --print "landed in water"
    hero:show_ground_effect("water")
    audio_manager:play_sound("walk_on_water")
  elseif ground=="grass" then
    --print "landed in grass"
    hero:show_ground_effect("grass")
    audio_manager:play_sound("walk_on_grass")
  elseif ground=="deep_water" or ground=="lava" then
    --print "plundged in some fluid"
    audio_manager:play_sound("splash")
  else --Not a standard ground
    --print "landed in some other ground"
    for entity in map:get_entities_in_rectangle(x,y,1,1) do
      if entity:get_property("custom_ground")=="sand" then
        --print "landed in sand"
        hero:show_ground_effect("sand") --TODO make proper sprite for sand landing effect
      end
      audio_manager:play_sound("hero_lands")
    end
  end
end

return true

return function(small_bowwow)
  
  -- Variables
  local game = small_bowwow:get_game()
  local map = small_bowwow:get_map()
  local sprite = small_bowwow:get_sprite()
  
  -- Include scripts
  require("scripts/multi_events")
  local audio_manager = require("scripts/audio_manager")
  
  -- Small bowow animation
  local function launch_animation()
    
    local rand4 = math.random(4)
    local direction8 = rand4 * 2 - 1
    local angle = direction8 * math.pi / 4
    local m = sol.movement.create("straight")
    m:set_speed(48)
    m:set_angle(angle)
    m:set_max_distance(24 + math.random(96))
    m:start(small_bowwow)
    sprite:set_direction(rand4 - 1)
    sol.timer.stop_all(small_bowwow)
    
  end

  -- Small bowwow events
  small_bowwow:register_event("on_created", function()

    launch_animation()

  end)

  small_bowwow:register_event("on_obstacle_reached", function()

    launch_animation()

  end)

  small_bowwow:register_event("on_movement_finished", function()

    launch_animation()

  end)
  
end
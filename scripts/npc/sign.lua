return function(sign)
  
  -- Variables
  local game = sign:get_game()
  local map = sign:get_map()
  local hero = map:get_hero()
  
  -- Include scripts
  require("scripts/multi_events")
  local audio_manager = require("scripts/audio_manager")
  sign:set_weight(0)


  -- Sign destruction
  function sign:destroy()
    
    sign:set_weight(-1)
    audio_manager:play_sound("environment/sign_slice")
    local sprite = sign:get_sprite()
    function sprite:on_animation_finished(animation)
      if animation == "sliced" then
        sprite:set_animation("sliced_destroy")
      elseif animation == "sliced_destroy" then
        sprite:set_animation("naked")
      end
    end
    sprite:set_animation("sliced")
    
  end
  
  -- Timer
  sol.timer.start(sign, 50, function()
    local sword_sprite = hero:get_sprite("sword")
    local sign_sprite = sign:get_sprite()
    if hero:overlaps(sign, "sprite", sword_sprite, sign_sprite) and (hero:get_state() == "sword swinging" or hero:get_state() == "sword spin attack") then
      if sign_sprite:get_animation() == "stopped" then
        sign:destroy()
      end
    end
    return true
  end)
  
  -- Sign events     
  sign:register_event("on_interaction", function()
     
    if sign:get_sprite():get_animation() == "stopped" then
      local dialogue_id = sign:get_property("dialogue_id")
      if dialogue_id ~= nil then
        game:start_dialog(dialogue_id)
      end
    end

  end)
  
end


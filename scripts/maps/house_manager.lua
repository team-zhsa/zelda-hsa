-- This scripts blocks the commands: attack, item_1 and item_2.
-- It is aimed to be used in maps that are inside houses.
--
-- Usage:
-- local house_manager = require("scripts/maps/house_manager")
--
-- function map:on_started(destination)
--   house_manager:init(map)
-- end

local house_manager = {}

function house_manager:init(map)
  -- One instance per map.
  local instance = {}

  -- initialise the feature.
  function instance:init(map)
    instance.hud = map:get_game():get_hud()

    -- Adapt the HUD.
    instance.command_attack_active = instance.hud:is_command_icon_active("attack")
    instance.command_item_1_active = instance.hud:is_command_icon_active("item_1")
    instance.command_item_2_active = instance.hud:is_command_icon_active("item_2")
    instance:adapt_hud()

    -- Block the attack and items.
    map:register_event("on_command_pressed", function(map, command)
      if command == "attack" then
          return true
      elseif command == "item_1" then
        return true
      elseif command == "item_2" then
        return true
      end 
    end)
  
    -- Restore the HUD after the hero leaves the map.
    map:register_event("on_finished", function(map, command)
      if instance.command_attack_active ~= nil then
        instance.hud:set_command_icon_active("attack", instance.command_attack_active)
      end
    
      if instance.command_item_1_active ~= nil then
        instance.hud:set_command_icon_active("item_1", instance.command_item_1_active)
      end
  
      if instance.command_item_2_active ~= nil then
        instance.hud:set_command_icon_active("item_2", instance.command_item_2_active)
      end
    end)
  end

  -- Re-adapt the hud when the game is un-paused.
  map:register_event("on_suspended", function(map, suspended)
    if not suspended then
      instance:adapt_hud()
    end
  end)

  -- Adapt the hud: grey-out commands.
  function instance:adapt_hud()
    instance.hud:set_command_icon_active("attack", false)
    instance.hud:set_command_icon_active("item_1", false)
    instance.hud:set_command_icon_active("item_2", false)
  end

  -- First initialization.
  instance:init(map)

  return instance

end

return house_manager

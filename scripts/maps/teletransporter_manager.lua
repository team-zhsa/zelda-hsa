local teletransporter_manager = {}
require("scripts/multi_events")

local game_meta = sol.main.get_metatable("game")

game_meta:register_event("on_map_changed", function(game, map)
    print("Changed map to '" .. map:get_id() .. "'")
    local camera = map:get_camera()
    local surface = camera:get_surface()
    local hero = map:get_hero()
    -- Browse all teletransporters
    for teletransporter in map:get_entities_by_type("teletransporter") do
      local effect = teletransporter:get_property("effect")
      if effect ~= nil then
        teletransporter:register_event("on_activated", function(teletransporter)
          teletransporter:set_enabled(false)
          local destination_map = teletransporter:get_destination_map()
          local destination_name = teletransporter:get_destination_name()
          local x_teletransporter, y_teletransporter = teletransporter:get_position()
          local effect_model = require("scripts/gfx_effects/" .. effect)
          game:set_suspended(true)
          game:set_pause_allowed(false)
          game.teleport_in_progress=true
          -- Execute In effect
          effect_model.start_effect(surface, game, "in", false, function()
            if destination_name == "_side" then
              local w_map, h_map = map:get_size()
              -- We calculate the direction according to the position of the teletransporter on the map
              local side = 0
              if y_teletransporter == h_map then
                side = 1
              elseif x_teletransporter == w_map then
                side = 2
              elseif y_teletransporter == -16 then
                side = 3
              end
              hero:teleport(destination_map, "_side" .. side, "immediate")
              game.map_in_transition = effect_model
            elseif destination_map ~= map:get_id() then
              hero:teleport(destination_map, destination_name, "immediate")
              game.map_in_transition = effect_model
            else
              hero:teleport(destination_map, destination_name, "immediate")
              effect_model.start_effect(surface, game, "out", false, function()
                game.teleport_in_progress=nil
                game:set_suspended(true)
                game:set_pause_allowed(false)
              end)
            end
          end)
        end)
      end
    end
    -- Execute Out effect
    if game.map_in_transition ~= nil then
      game:set_suspended(true)
      game:set_pause_allowed(false)
      game.map_in_transition.start_effect(surface, game, "out", false, function()
          debug_print("End of inter-maps custom transition")
          game.teleport_in_progress=nil
          game:set_suspended(false)
          game:set_pause_allowed(true)
          if map.do_after_transition then
            map.do_after_transition()
          end
        end)
      game.map_in_transition = nil
    end

  end)

return teletransporter_manager
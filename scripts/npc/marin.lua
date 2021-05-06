return function(marin)
  
  -- Variables
  local game = marin:get_game()
  local map = marin:get_map()
  local marin_notes = nil
  local marin_notes_2 = nil
  local marin_is_sing = false

  -- Include scripts
  local audio_manager = require("scripts/audio_manager")
  
  function marin:sing_start()

    local map = game:get_map()
    marin:sing_start_animation(map)
    sol.audio.stop_music()
    audio_manager:play_music("44_song_of_marin")
    
  end

  function marin:sing_start_animation(map)
    
    marin_is_sing = true
    local x,y,layer = marin:get_position()
    marin_notes = map:create_custom_entity{
      x = x,
      y = y - 16,
      layer = layer + 1,
      width = 24,
      height = 32,
      direction = 0,
      sprite = "entities/symbols/notes"
    }
    marin_notes_2 = map:create_custom_entity{
      x = x,
      y = y - 16,
      layer = layer + 1,
      width = 24,
      height = 32,
      direction = 2,
      sprite = "entities/symbols/notes"
    }
    marin:get_sprite():set_animation("singing")
    
  end

  function marin:sing_stop()

  sol.audio.stop_music()
  marin:sing_stop_animation()

  end

  function marin:sing_stop_animation(map)

    marin_is_sing = false
    marin:get_sprite():set_animation("waiting")
    if marin_notes ~= nil then
      marin_notes:remove()
    end
    if marin_notes_2 ~= nil then
      marin_notes_2:remove()
    end

  end

  function marin:launch_cinematic_marin_singing_with_hero(map)

    local hero = map:get_hero()
    local x_marin, y_marin, layer_marin = marin:get_position()
    local x_hero, y_hero, layer_hero = hero:get_position()
    map:start_coroutine(function()
      local options = {
        entities_ignore_suspend = {hero, marin}
      }
      map:set_cinematic_mode(true, options)
      -- Marin sing alone
      audio_manager:play_music("38_song_of_marin_and_link")
      marin:sing_start_animation(map)
      wait(7500)
      hero:set_direction(3)
      marin:sing_stop_animation(map)
      -- Hero sing alone
      local hero_notes = map:create_custom_entity{
        x = x_hero,
        y = y_hero - 16,
        layer = layer_hero + 1,
        width = 24,
        height = 32,
        direction = 0,
        sprite = "entities/symbols/notes"
      }
      local hero_notes_2 = map:create_custom_entity{
        x = x_hero,
        y = y_hero - 16,
        layer = layer_hero + 1,
        width = 24,
        height = 32,
        direction = 2,
        sprite = "entities/symbols/notes"
      }
      hero:set_animation("playing_ocarina")
      wait(8000)
      -- Marin sing too
      marin:sing_start_animation(map)
      wait(17500)
      map:set_cinematic_mode(false, options)
      hero:set_animation("stopped")
      if hero_notes ~= nil then
        hero_notes:remove()
      end
      if hero_notes_2 ~= nil then
        hero_notes_2:remove()
      end
      marin:sing_stop()
      local direction4 = hero:get_direction4_to(marin)
      hero:set_direction(direction4)
      if dialog("maps.out.mabe_village.marin_5") == 1 then
        local item_melody = game:get_item("melody_1")
        item_melody:set_variant(1)
        item_melody:brandish(function()
          game:start_dialog("maps.out.mabe_village.marin_7", function()
            marin:get_sprite():set_direction(3)
          end)
        end)
        wait(500)
        map:init_music()
      else
        dialog("maps.out.mabe_village.marin_6")
        marin:get_sprite():set_direction(3)
        map:launch_cinematic_marin_singing_with_hero(map)
      end
    end)

  end

  function marin:is_sing()
    
    return marin_is_sing
      
  end
  
end



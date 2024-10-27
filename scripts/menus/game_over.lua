-- Script that creates a game-over menu for a game.

-- Usage:
-- require("scripts/menus/game_over")

require("scripts/multi_events")
local automation = require("scripts/automation/automation")
local messagebox = require("scripts/menus/messagebox")
local audio_manager = require("scripts/audio_manager")
local language_manager = require("scripts/language_manager")

-- Creates and sets up a game-over menu for the specified game.
local function initialise_game_over_features(game)

  if game.game_over_menu ~= nil then
    -- Already done.
    return
  end

  -- Sets the menu on the game.
  local game_over_menu = {}
  game.game_over_menu = game_over_menu

  -- Start the game over menu when the game needs it.
  game:register_event("on_game_over_started", function(game)
    -- Attach the game-over menu to the map so that the map's fade-out
    -- effect applies to it when restarting the game.
      sol.menu.start(game:get_map(), game_over_menu)
  end)


  
  function game_over_menu:on_started()
    local quest_w, quest_h = sol.video.get_quest_size()
    
    local music
    local background_img
    local hero_was_visible
    local hero_dead_sprite
    local fade_sprite
    local fairy_sprite
    local cursor_position
    local state
    
    -- Adapt the HUD
    game_over_menu:backup_game_state()
    game:set_hud_mode("no_buttons")
    game:bring_hud_to_front()
    game:set_custom_command_effect("action", "")
    game:set_custom_command_effect("attack", "")
    game:get_hero():set_visible(false)
    
    -- Steps
    game_over_menu.steps = {
      "wait_start", -- The game-over scene will start soon.
      "fade_in", -- Fade-out on the game screen.
      "red_screen", -- Red screen during a small delay.
      "fairy", -- The player is being saved by a fairy.
      "title", -- Setting up the game-over menu.
      "ask_menu", -- The player can choose an option in the game-over menu.
      "finished" -- An action was validated in the menu.
    }
    local function invert_table(t)
      local s = {}
      for k, v in pairs(t) do
        s[v] = k
      end
      return s
    end

    game_over_menu.step_indexes = invert_table(game_over_menu.steps)
    game_over_menu.step_index = 0

    -- Letters
    game_over_menu.title_w, game_over_menu.title_h = 120, 23
    game_over_menu.title_x, game_over_menu.title_y = math.ceil((quest_w - game_over_menu.title_w) / 2), 32
    game_over_menu.letters = {
      { name = "g", offset = 0},
      { name = "a", offset = 20},
      { name = "m", offset = 33},
      { name = "e", offset = 49},
      { name = "o", offset = 65},
      { name = "v", offset = 86},
      { name = "e", offset = 99},
      { name = "r", offset = 107},
    } 
    game_over_menu.anim_duration = 1000
    for _, letter in pairs(game_over_menu.letters) do
      local sprite = sol.sprite.create("menus/game_over/game_over_title")
      sprite:set_animation(letter.name)
      local x, y = game_over_menu.title_x + letter.offset, - game_over_menu.title_h
      sprite:set_xy(x, y)
      letter.sprite = sprite
      letter.automation = automation:new(
        game_over_menu, sprite, "back_in_out",
        game_over_menu.anim_duration, { y = game_over_menu.title_y})
    end

    -- Sprites.
    local map = game:get_map()
    local camera_x, camera_y = map:get_camera():get_position()
    local hero = game:get_hero()
    local hero_x, hero_y = game:get_hero():get_position()
    game_over_menu.hero_dead_x, game_over_menu.hero_dead_y = hero_x - camera_x, hero_y - camera_y
    local tunic = game:get_ability("tunic")
    game_over_menu.hero_dead_sprite = sol.sprite.create("hero/tunic" .. tunic)
    game_over_menu.hero_dead_sprite:set_animation("hurt")
    game_over_menu.hero_dead_sprite:set_direction(game:get_hero():get_direction())
    game_over_menu.hero_dead_sprite:set_paused(true)
    game_over_menu.hero_dead_sprite:set_xy(game_over_menu.hero_dead_x, game_over_menu.hero_dead_y)

    game_over_menu.background_red = sol.surface.create(quest_w, quest_h)
    game_over_menu.background_red:fill_color({128, 0, 0})
    game_over_menu.background_red:set_opacity(0)
    game_over_menu.background_black = sol.surface.create(quest_w, quest_h)
    game_over_menu.background_black:fill_color({0, 0, 0})
    game_over_menu.background_black:set_opacity(0)
    game_over_menu.fade_sprite = sol.sprite.create("menus/game_over/game_over_fade")
    game_over_menu.fade_sprite:set_xy(game_over_menu.hero_dead_x, game_over_menu.hero_dead_y)
    game_over_menu.fairy_sprite = sol.sprite.create("entities/fairy")
    game_over_menu.fairy_sprite:set_animation("fairy")
    game_over_menu.powder_sprite = sol.sprite.create("entities/fairy")
    game_over_menu.powder_sprite:set_animation("powder")
    game_over_menu.cursor_position = 0
    game_over_menu.cursor_field_x = quest_w/2 - 104
    game_over_menu.cursor_field_y = quest_h/2 - 8

    game_over_menu.text_save_continue = sol.text_surface.create({
      font = language_manager:get_dialog_font(),
      text_key = "game_over.save_continue",})
    game_over_menu.text_save_continue:set_xy(
      game_over_menu.cursor_field_x + 24,
      game_over_menu.cursor_field_y + 0 * 20 - 4)
      
    game_over_menu.text_save_quit = sol.text_surface.create({
      font = language_manager:get_dialog_font(),
      text_key = "game_over.save_quit",})
    game_over_menu.text_save_quit:set_xy(
      game_over_menu.cursor_field_x + 24, 
      game_over_menu.cursor_field_y + 1 * 20 - 4)
          
    game_over_menu.text_retry = sol.text_surface.create({
      font = language_manager:get_dialog_font(),
      text_key = "game_over.retry",})
    game_over_menu.text_retry:set_xy(
      game_over_menu.cursor_field_x + 24, 
      game_over_menu.cursor_field_y + 2 * 20 - 4)

    game_over_menu.text_quit = sol.text_surface.create({
      font = language_manager:get_dialog_font(),
      text_key = "game_over.quit",})
    game_over_menu.text_quit:set_xy(
      game_over_menu.cursor_field_x + 24,
      game_over_menu.cursor_field_y + 3 * 20 - 4)
          
    -- Launch the animation.
    game_over_menu:set_step(1)
  end

  -- Goes to the menu's next step.
  function game_over_menu:next_step()
    game_over_menu:set_step(game_over_menu.step_index + 1)
  end

  -- Sets the specific step to the menu.
  function game_over_menu:set_step(step_index)
    step_index = math.min(step_index, #game_over_menu.steps)
    game_over_menu.step_index = step_index

    local step = game_over_menu.steps[step_index]
    if step == "wait_start" then
      game_over_menu:step_wait_start()
    elseif step == "fade_in" then
      game_over_menu:step_fade_in()
    elseif step == "red_screen" then
      game_over_menu:step_red_screen()
    elseif step == "fairy" then
      game_over_menu:step_fairy()
    elseif step == "title" then
      game_over_menu:step_title()
    elseif step == "ask_menu" then
      game_over_menu:step_ask_menu()
    elseif step == "finished" then
      game_over_menu:step_finish()
    end
  end

  -- Saves the current game state, to restore it after the menu
  -- is finished.
  function game_over_menu:backup_game_state()
    game_over_menu.backup_action = game:get_custom_command_effect("action")
    game_over_menu.backup_attack = game:get_custom_command_effect("attack")
    game_over_menu.backup_hud_mode = game:get_hud_mode()
    game_over_menu.backup_music = sol.audio.get_music()
    local hero = game:get_hero()
    game_over_menu.backup_hero_visible = hero:is_visible()
  end

  -- Restores the game state to what it was before starting the menu.
  function game_over_menu:restore_game_state(restore_music)
    -- Restore hero.
    local hero = game:get_hero()
    if hero ~= nil then
      hero:set_visible(game_over_menu.backup_hero_visible)
    end

    -- Restore HUD.
    game:set_custom_command_effect("action", game_over_menu.backup_action)
    game:set_custom_command_effect("attack", game_over_menu.backup_attack)
    game:set_hud_mode(game_over_menu.backup_hud_mode)

    -- Restore music.
    if restore_music then
      sol.audio.play_music(game_over_menu.backup_music)
    end
  end

  -- Step 1: Starting up.
  function game_over_menu:step_wait_start()
    game_over_menu:next_step()
  end

  -- Step 2: Menu fade-in.
  function game_over_menu:step_fade_in()
    sol.audio.stop_music()
    game_over_menu.fade_sprite:set_animation("close", function()
      game_over_menu.background_black:set_opacity(255)
      game_over_menu.background_red:set_opacity(255)
      game_over_menu:next_step()
    end)
    game_over_menu.hero_dead_sprite:set_direction(0)
    game_over_menu.hero_dead_sprite:set_paused(false)
    game_over_menu.hero_dead_sprite:set_animation("dying")
    sol.audio.play_sound("hero/hero_dying")
  end
  
  -- Step 3: Red screen
  function game_over_menu:step_red_screen()
    sol.timer.start(self, 2000, function()
      game_over_menu.background_red:fade_out()
      game_over_menu:next_step()
    end)
  end

  -- Step 4: heal the hero if he has a fairy in a bottle.
  function game_over_menu:step_fairy()
    -- Check if the player has a fairy.
    local bottle_with_fairy = game:get_first_bottle_with(6)
    -- Has a fairy.
    if bottle_with_fairy ~= nil then
      -- Make the bottle empty.
      bottle_with_fairy:set_variant(1)
      -- Fairy animation
      game_over_menu.powder_sprite:set_xy(game_over_menu.hero_dead_x, game_over_menu.hero_dead_y)
      game_over_menu.powder_sprite:set_opacity(0)
      game_over_menu.fairy_sprite:set_xy(game_over_menu.hero_dead_x - 200, game_over_menu.hero_dead_y - 64)
      local movement_1 = sol.movement.create("target")
      movement_1:set_target(game_over_menu.hero_dead_x, game_over_menu.hero_dead_y - 24)
      movement_1:set_speed(156)
      movement_1:start(game_over_menu.fairy_sprite, function()
        game_over_menu.fairy_sprite:set_animation("wand")
        sol.audio.play_sound("objects/fairy/interact")
        game_over_menu.powder_sprite:fade_in()
        sol.timer.start(game_over_menu, 1200, function()
          game_over_menu.powder_sprite:fade_out()
          game_over_menu.fairy_sprite:set_animation("fairy")
          local movement_2 = sol.movement.create("target")
          movement_2:set_target(game_over_menu.hero_dead_x + 200, game_over_menu.hero_dead_y - 64)
          movement_2:set_speed(156)
          movement_2:start(game_over_menu.fairy_sprite, function()
            local restored_heart_count = 6
            game:add_life(restored_heart_count * 4)  -- Restore 6 hearts.
            sol.timer.start(self, 250 * restored_heart_count, function()
              sol.audio.play_music(game_over_menu.backup_music)
              game:stop_game_over()
              game_over_menu:restore_game_state(true)
              sol.menu.stop(game_over_menu)
              local map = game:get_map()
              if not game.teleport_in_progress then -- play custom transition at game startup
                game:set_suspended(true)
                local opening_transition = require("scripts/gfx_effects/radial_fade_out")
                opening_transition.start_effect(map:get_camera():get_surface(), game, "out", nil, function()
                  game:set_suspended(false)
                  if map.do_after_transition then
                    map.do_after_transition()
                  end
                end)
              end
            end)
          end)
        end)
      end)
    else
      -- Go to next step.
      game_over_menu:next_step()
    end
  end

  -- Step 5: show the Game Over title.
  function game_over_menu:step_title()
    -- Add the death to the total death count.
    local death_count = game:get_value("stats_hero_death_count") or 0
    game:set_value("stats_hero_death_count", death_count + 1)
    -- Hide the hero.
    game_over_menu.hero_dead_sprite:fade_out(10, function()
      -- Launch animations.
      local letter_count = #game_over_menu.letters
      for i, letter in ipairs(game_over_menu.letters) do
        local timer_delay = (i - 1) * game_over_menu.anim_duration / 6
        if i == letter_count then
          letter.automation.on_finished = function()
            game_over_menu:next_step()
          end
        end
        sol.timer.start(game_over_menu, timer_delay, function()
          letter.automation:start()
        end)
      end
    end)
  end

  -- Step 6: Asking menu
  function game_over_menu:step_ask_menu() 
    -- Play the game over music.
    sol.audio.play_music("cutscenes/game_over")         
    game_over_menu.fairy_sprite:set_xy(game_over_menu.cursor_field_x, game_over_menu.cursor_field_y)  -- Cursor.
    game_over_menu.cursor_position = 0
  end

  function game_over_menu:on_draw(dst_surface)
    if game_over_menu.step_index >= game_over_menu.step_indexes["fade_in"] then
      -- Hide the whole map.
      game_over_menu.background_black:draw(dst_surface)
      game_over_menu.background_red:draw(dst_surface)
      game_over_menu.fade_sprite:draw(dst_surface)
    end

    -- Title.
    for _, letter in pairs(game_over_menu.letters) do
      letter.sprite:draw(dst_surface)
    end
    -- Hero.
    game_over_menu.hero_dead_sprite:draw(dst_surface)
    game_over_menu.fairy_sprite:draw(dst_surface)
    game_over_menu.powder_sprite:draw(dst_surface)

    if game_over_menu.step_index >= game_over_menu.step_indexes["ask_menu"] then
      game_over_menu.text_save_continue:draw(dst_surface)
      game_over_menu.text_save_quit:draw(dst_surface)
      game_over_menu.text_retry:draw(dst_surface)
      game_over_menu.text_quit:draw(dst_surface)
    end
  end

  function game_over_menu:on_command_pressed(command)

    if game_over_menu.step_index ~= game_over_menu.step_indexes["ask_menu"] then
      -- Commands are not available during the game-over opening animations.
      return
    end

    if command == "down" then
      sol.audio.play_sound("menus/cursor")
      game_over_menu.cursor_position = (game_over_menu.cursor_position + 1) % 4
      local fairy_x, fairy_y = game_over_menu.fairy_sprite:get_xy()
      fairy_y = game_over_menu.cursor_field_y + game_over_menu.cursor_position * 20
      game_over_menu.fairy_sprite:set_xy(fairy_x, fairy_y)
    elseif command == "up" then
      sol.audio.play_sound("menus/cursor")
      game_over_menu.cursor_position = (game_over_menu.cursor_position + 3) % 4
      local fairy_x, fairy_y = game_over_menu.fairy_sprite:get_xy()
      fairy_y = game_over_menu.cursor_field_y + game_over_menu.cursor_position * 20
      game_over_menu.fairy_sprite:set_xy(fairy_x, fairy_y)
    elseif command == "action" or command == "attack" then
      game_over_menu.step_index = game_over_menu.step_indexes["finished"]
      sol.audio.play_sound("menus/danger")
      --game:set_hud_enabled(false)
      local restored_heart_count = 6
      if game_over_menu.cursor_position == 0 then
        -- Save and continue.
        game:add_life(restored_heart_count * 4)
        game:save()
        -- Wait for the hearts to be refilled before quitting the menu.
        sol.timer.start(game_over_menu, 250 * restored_heart_count, function()
          game_over_menu:restore_game_state(false)
          game:set_hud_enabled(false)
          game:start()
        end)
      elseif game_over_menu.cursor_position == 1 then
        -- Save and quit.
        game:add_life(restored_heart_count * 4)
        game:save()
        sol.main.reset()
      elseif game_over_menu.cursor_position == 2 then
        -- Continue without saving.
        -- Wait for the hearts to be refilled before quitting the menu.
        sol.timer.start(game_over_menu, 250 * restored_heart_count, function()
          game_over_menu:restore_game_state(false)
          game:set_hud_enabled(false)
          game:start()
        end)
      elseif game_over_menu.cursor_position == 3 then
        -- Quit without saving.
        sol.main.reset()
      end
    end
  end
end

-- Set up the game-over menu on any game that starts.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", initialise_game_over_features)

return true
-- Script that creates a game-over menu for a game.

-- Usage:
-- require("scripts/menus/game_over")

require("scripts/multi_events")

-- Creates and sets up a game-over menu for the specified game.
local function initialise_game_over_features(game)

  if game.game_over_menu ~= nil then
    -- Already done.
    return
  end

  local game_over_menu = {}  -- The game-over menu.
  game.game_over_menu = game_over_menu

  local music
  local background_img
  local hero_was_visible
  local hero_dead_sprite
  local hero_dead_x, hero_dead_y
  local fade_sprite
  local fairy_sprite
  local cursor_position
  local state

  -- state can be one of:
  -- "waiting_start": The game-over scene will start soon.
  -- "closing_game": Fade-out on the game screen.
  -- "red_screen": Red screen during a small delay.
  -- "opening_menu": Fade-in on the game-over menu.
  -- "saved_by_fairy": The player is being saved by a fairy.
  -- "waiting_end": The game will be resumed soon.
  -- "resume_game": The game can be resumed.
  -- "menu": The player can choose an option in the game-over menu.
  -- "finished": An action was validated in the menu.

  game:register_event("on_game_over_started", function(game)

    -- Attach the game-over menu to the map so that the map's fade-out
    -- effect applies to it when restarting the game.
    sol.menu.start(game:get_map(), game_over_menu)
  end)

  function game_over_menu:on_started()

    local hero = game:get_hero()
    hero_was_visible = hero:is_visible()
    hero:set_visible(false)
    music = sol.audio.get_music()
    background_img = sol.surface.create("gameover_menu.png", true)
    local tunic = game:get_ability("tunic")
    hero_dead_sprite = sol.sprite.create("hero/tunic" .. tunic)
    hero_dead_sprite:set_animation("hurt")
    hero_dead_sprite:set_direction(hero:get_direction())
    hero_dead_sprite:set_paused(true)
    fade_sprite = sol.sprite.create("hud/gameover_fade")
    fairy_sprite = sol.sprite.create("entities/fairy")
    fairy_sprite:set_animation("fairy")
    powder_sprite = sol.sprite.create("entities/fairy")
    powder_sprite:set_animation("powder")
    state = "waiting_start"

    local map = game:get_map()
    local camera_x, camera_y = map:get_camera():get_position()
    local hero_x, hero_y = hero:get_position()
    hero_dead_x = hero_x - camera_x
    hero_dead_y = hero_y - camera_y

    sol.timer.start(self, 500, function()
      state = "closing_game"
      sol.audio.stop_music()
      fade_sprite:set_animation("close")
      fade_sprite.on_animation_finished = function()
        if state == "closing_game" then
          state = "red_screen"
          sol.audio.play_sound("hero/hero_dying")
          hero_dead_sprite:set_paused(false)
          hero_dead_sprite:set_direction(0)
          hero_dead_sprite:set_animation("dying")
          sol.timer.start(self, 2000, function()
            state = "opening_menu"
            fade_sprite:set_animation("open")
          end)
        elseif state == "opening_menu" then
          local bottle_with_fairy = game:get_first_bottle_with(6)
          if bottle_with_fairy ~= nil then            -- Has a fairy.
            state = "saved_by_fairy"

            -- Make the bottle empty.
            bottle_with_fairy:set_variant(1)
            powder_sprite:set_xy(hero_dead_x, hero_dead_y)
            powder_sprite:set_opacity(0)
            fairy_sprite:set_xy(hero_dead_x - 200, hero_dead_y - 64)
            local movement_1 = sol.movement.create("target")
            movement_1:set_target(hero_dead_x, hero_dead_y - 24)
            movement_1:set_speed(156)
            movement_1:start(fairy_sprite, function()
              fairy_sprite:set_animation("wand")
              sol.audio.play_sound("objects/fairy/interact")
              powder_sprite:fade_in()
              sol.timer.start(self, 1200, function()
                powder_sprite:fade_out()
                fairy_sprite:set_animation("fairy")
                local movement_2 = sol.movement.create("target")
                movement_2:set_target(hero_dead_x + 200, hero_dead_y - 64)
                movement_2:set_speed(156)
                movement_2:start(fairy_sprite, function()
                  state = "waiting_end"
                  game:add_life(6 * 4)  -- Restore 7 hearts.
                  sol.timer.start(self, 1000, function()
                    state = "resume_game"
                    sol.audio.play_music(music)
                    game:stop_game_over()
                    sol.menu.stop(self)
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
            -- No fairy: game over.
            state = "menu"
            sol.audio.play_music("cutscenes/game_over")
            fairy_sprite:set_xy(76, 112)  -- Cursor.
            cursor_position = 0
            local death_count = game:get_value("death_count") or 0
            game:set_value("death_count", death_count + 1)
          end

        end
      end
    end)
  end

  function game_over_menu:on_finished()

    local hero = game:get_hero()
    if hero ~= nil then
      hero:set_visible(hero_was_visible)
    end
    music = nil
    background_img = nil
    hero_dead_sprite = nil
    fade_sprite = nil
    fairy_sprite = nil
    cursor_position = nil
    state = nil
    sol.timer.stop_all(self)
  end

  local black = {0, 0, 0}
  local red = {255, 64, 61}

  function game_over_menu:on_draw(dst_surface)

    if state ~= "waiting_start" and state ~= "closing_game" then
      -- Hide the whole map.
      dst_surface:fill_color(black)
    end

    if state == "closing_game"
        or state == "opening_menu" then
      fade_sprite:draw(dst_surface, hero_dead_x, hero_dead_y)
    elseif state == "red_screen" then
      dst_surface:fill_color(red)
    end

    if state == "menu" or state == "finished" then
      background_img:draw(dst_surface)
      fairy_sprite:draw(dst_surface)
    elseif state ~= "resume_game" then
      hero_dead_sprite:draw(dst_surface, hero_dead_x, hero_dead_y)
      if state == "saved_by_fairy" then
        fairy_sprite:draw(dst_surface)
        powder_sprite:draw(dst_surface)
      end
    end
  end

  function game_over_menu:on_command_pressed(command)

    if state ~= "menu" then
      -- Commands are not available during the game-over opening animations.
      return
    end

    if command == "down" then
      sol.audio.play_sound("menus/cursor")
      cursor_position = (cursor_position + 1) % 4
      local fairy_x, fairy_y = fairy_sprite:get_xy()
      fairy_y = 112 + cursor_position * 16
      fairy_sprite:set_xy(fairy_x, fairy_y)
    elseif command == "up" then
      sol.audio.play_sound("menus/cursor")
      cursor_position = (cursor_position + 3) % 4
      local fairy_x, fairy_y = fairy_sprite:get_xy()
      fairy_y = 112 + cursor_position * 16
      fairy_sprite:set_xy(fairy_x, fairy_y)
    elseif command == "action" or command == "attack" then

      state = "finished"
      sol.audio.play_sound("menus/danger")
      game:set_hud_enabled(false)
      game:add_life(6 * 4)  -- Restore 7 hearts.

      if cursor_position == 0 then
        -- Save and continue.
        game:save()
        game:start()
      elseif cursor_position == 1 then
        -- Save and quit.
        game:save()
        sol.main.reset()
      elseif cursor_position == 2 then
        -- Continue without saving.
        game:start()
      elseif cursor_position == 3 then
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


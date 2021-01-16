-- Lua script of map out/b3.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local camera = map:get_camera()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
	game:set_value("game_kakarico_maze", 1)
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

-- Maze game:

function camera_go_switch()
  local m = sol.movement.create("target")
	m:set_target(switch_maze_game, -152, -112)
	m:set_ignore_obstacles(true)
  m:set_speed(500)
	m:start(camera, function()
		sol.timer.start(map, 1000, function()
			camera_go_hero()
		end)
	end)
end

function camera_go_hero()
  local m = sol.movement.create("target")
	m:set_target(hero, -152, -112)
	m:set_ignore_obstacles(true)
  m:set_speed(500)
	m:start(camera, function()
		camera:start_tracking(hero)
		play_maze()
	end)
end


-- --------------------------------------------------------------------------------------------

local playing_maze_game = false
local maze_game_timer
local maze_game_dialog_finished


function npc_maze_game:on_interaction() -- Maze game NPC

  if playing_maze_game then
    -- the player is already playing: let him restart the game
    game:start_dialog("rupee_house.game_3.restart_question", game_3_question_dialog_finished)
  else
    -- see if the player can still play
    local unauthorized = game:get_value("b17")

    if unauthorized then
      -- the player already won this game
      game:start_dialog("rupee_house.game_3.not_allowed_to_play")
    else
      -- game rules
      game:start_dialog("rupee_house.game_3.intro", game_3_question_dialog_finished)
    end
  end
end

function game_3_question_dialog_finished(answer)

  if answer == 2 then
    -- don't want to play the game
    game:start_dialog("rupee_house.game_3.not_playing")
  else
    -- wants to play game 3

    if game:get_money() < 10 then
      -- not enough money
      sol.audio.play_sound("wrong")
      game:start_dialog("rupee_house.not_enough_money")

    else
      -- enough money: reset the game, pay and start the game
      map:reset_blocks()
      game_3_barrier_1:set_enabled(false)
      game_3_barrier_2:set_enabled(false)
      game_3_barrier_3:set_enabled(false)
      game_3_middle_barrier:set_enabled(false)
      if game_3_timer ~= nil then
        game_3_timer:stop()
        game_3_timer = nil
      end

      game:remove_money(10)
      game:start_dialog("rupee_house.game_3.go", function()
        game_3_timer = sol.timer.start(8000, function()
          sol.audio.play_sound("door_closed")
          sol.timer.start(10, function()
            if game_3_middle_barrier:overlaps(hero) then
              return true -- Repeat the timer.
            else
              game_3_middle_barrier:set_enabled(true)
            end
          end)
        end)

        game_3_timer:set_with_sound(true)
        game_3_sensor:set_enabled(true)
      end)
      playing_game_3 = true
    end
  end
end

function map:on_obtained_treasure(item, variant, savegame_variable)
  -- stop game 3 when the player finds the piece of heart
  if item:get_name() == "piece_of_heart" then
    game_3_final_barrier:set_enabled(false)
    sol.audio.play_sound("secret")
    playing_game_3 = false
  end
end
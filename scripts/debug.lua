-- Adds cheating keys and a Lua console to ease debugging.
-- Debugging is enabled if there exists a file called "debug"
-- or "debug.lua" in the write directory.

-- Usage:
-- require("scripts/debug")

if not sol.file.exists("debug") and not sol.file.exists("debug.lua") then
  return true
end

local console = require("scripts/console")
local game_manager = require("scripts/game_manager")	
local statistics_manager = require("scripts/menus/statistics")
local mode_7_manager = require("scripts/mode_7")
local debug = {}
local show_debug_info_screen=false
local debug_info_page=0
local debug_info_num_pages = 3

function debug:on_key_pressed(key, modifiers)

  local handled = true
  if key == "1" then
    if sol.game.exists("save1.dat") then
      sol.main:start_savegame(game_manager:create("save1.dat"))
    end
  elseif key == "2" then
    if sol.game.exists("save2.dat") then
      sol.main:start_savegame(game_manager:create("save2.dat"))
    end
  elseif key == "3" then
    if sol.game.exists("save3.dat") then
      sol.main:start_savegame(game_manager:create("save3.dat"))
    end
  elseif key == "f12" and not console.enabled then
    sol.menu.start(sol.main, console)
  elseif key == "f10" then
    show_debug_info_screen = not show_debug_info_screen
  elseif key == "kp +" then
    debug_info_page=(debug_info_page+1)%debug_info_num_pages
  elseif key == "kp -" then
    debug_info_page=(debug_info_page+debug_info_num_pages-1)%debug_info_num_pages
  elseif sol.main.game ~= nil and not console.enabled then
    local game = sol.main.game
		local map = game:get_map()
    local hero = nil
    if game ~= nil and game:get_map() ~= nil then
      hero = game:get_map():get_entity("hero")
    end



    -- In-game cheating keys.
    if key == "p" then
      game:add_life(4)
    elseif key == "o" then
      game:remove_life(4)
    elseif key == "m" then
      game:add_money(10)
    elseif key == "l" then
      game:remove_money(10)
    elseif key == "i" then
      game:add_magic(5)
    elseif key == "k" then
      game:remove_magic(5)
    elseif key == "kp 7" then
      game:set_max_magic(50)
    elseif key == "kp 8" then
      game:set_max_magic(100)
    elseif key == "kp 9" then
      game:set_max_magic(150)
    elseif key == "kp 1" then
      local tunic = game:get_item("tunic")
      local variant = math.max(1, tunic:get_variant() - 1)
      tunic:set_variant(variant)
      game:set_ability("tunic", variant)
    elseif key == "kp 4" then
      local tunic = game:get_item("tunic")
      local variant = math.min(3, tunic:get_variant() + 1)
      tunic:set_variant(variant)
      game:set_ability("tunic", variant)
    elseif key == "kp 2" then
      local sword = game:get_item("sword")
      local variant = math.max(1, sword:get_variant() - 1)
      sword:set_variant(variant)
    elseif key == "kp 5" then
      local sword = game:get_item("sword")
      local variant = math.min(4, sword:get_variant() + 1)
      sword:set_variant(variant)
    elseif key == "kp 3" then
      local shield = game:get_item("shield")
      local variant = math.max(1, shield:get_variant() - 1)
      shield:set_variant(variant)
    elseif key == "kp 6" then
      local shield = game:get_item("shield")
      local variant = math.min(3, shield:get_variant() + 1)
      shield:set_variant(variant)
    elseif key == "g" and hero ~= nil then
      local x, y, layer = hero:get_position()
      if layer ~= -1 then
        hero:set_position(x, y, layer - 1)
      end
    elseif key == "t" and hero ~= nil then
      local x, y, layer = hero:get_position()
      if layer ~= 2 then
        hero:set_position(x, y, layer + 1)
      end
    elseif key == "r" then
      if hero:get_walking_speed() == 400 then
        hero:set_walking_speed(debug.normal_walking_speed)
      else
        debug.normal_walking_speed = hero:get_walking_speed()
        hero:set_walking_speed(400)
      end
    elseif key == "s" then
      if game:is_suspended(false) then
        local statistics = statistics_manager:new(game)
        game:set_suspended(true)
        sol.menu.start(game, statistics)
        function statistics:on_finished()
          game:set_suspended(false)
        end
      end
		elseif key == "7" then
      local map_id = "out/a3"
      local destination_name = "from_flute"
      mode_7_manager:teleport(game, map:get_entity("hero"), map_id, destination_name)
    else
      -- Not a known in-game debug key.
      handled = false
    end
  else
    -- Not a known debug key.
    handled = false
  end

  return handled
end

-- The shift key skips dialogs
-- and the control key traverses walls.
local hero_movement = nil
local ctrl_pressed = false
function debug:on_update()

  local game = sol.main.game
  if game ~= nil then

    if game:is_dialog_enabled() then
      if sol.input.is_key_pressed("left shift") or sol.input.is_key_pressed("right shift") then
        game:get_dialog_box():show_all_now()
      end
    end

    local hero = game:get_hero()
    if hero ~= nil then
      if hero:get_movement() ~= hero_movement then
        -- The movement has changed.
        hero_movement = hero:get_movement()
        if hero_movement ~= nil
            and ctrl_pressed
            and not hero_movement:get_ignore_obstacles() then
          -- Also traverse obstacles in the new movement.
          hero_movement:set_ignore_obstacles(true)
        end
      end
      if hero_movement ~= nil then
        if not ctrl_pressed
            and (sol.input.is_key_pressed("left control") or sol.input.is_key_pressed("right control")) then
          hero_movement:set_ignore_obstacles(true)
          ctrl_pressed = true
        elseif ctrl_pressed
            and (not sol.input.is_key_pressed("left control") and not sol.input.is_key_pressed("right control")) then
          hero_movement:set_ignore_obstacles(false)
          ctrl_pressed = false
        end
      end
    end
  end
end

--[[
  ------------------------------------
  DEBUG INFORMATION DISPLAY
  ------------------------------------
--]]

--set up debug informations display
local debug_informations_text=sol.text_surface.create({
    vertical_alignment="top",
    font="enter_command_mono",
    font_size=17, 
  })
local debug_informations_background=sol.surface.create(sol.video.get_quest_size())

local function show_text(x,y,text)
  debug_informations_text:set_text(text)
  debug_informations_text:draw(debug_informations_background, x, y)
end

function debug:on_draw(dst_surface)
  local game = sol.main.get_game()
  if game then

    --show various information about the game on-screen, such as the moement parameters. Can be switched on and off by pressing F11
    --[[
      Common fields : XY, direction4
      
      Field         Straight/         Pathfinding/
                    Random/     Path  Rndm path      Circle     Jump  Pixel
                    /target
      -------------------------------------------
        Speed       X!           X!     X!                        X!
        Angle       X!           X!     X!              
        Max dist.   X!           -.     -
        smooth?     X!           -      -
        Path        -            X!     -
        Loop ?      -            X!     -                              X!
        Snaptogrid  -            X!     -
        Center      -           -      -              X!
        Radius                                        X!
        Radius_speed                                  X!
        Clockwise?                                    X!
        Angle from center                             X!
        Angular speed                                 X!
        Rotations                                     X!
        Duration                                      X!
        Loop delay                                    X!
        Direction8                                               X!
        Distance                                                 X!
        Trajectory                                                       X
        Delay                                                            X
        
        
        Lines 
        Speed / Anguler speed
        Angle / Angle from center
        Smoot / Loop / clockwise - able
    --]]
    if show_debug_info_screen then

      local hero=game:get_hero()
      local hero_movement=hero:get_movement()
      local map=game:get_map()
      local s=hero:get_state()
      debug_informations_background:clear()
      debug_informations_background:fill_color({64,64,64,192}) 
      debug_informations_text:set_color({255,255,255})
      show_text(270,0,"Page "..(debug_info_page+1).."/"..debug_info_num_pages)
      if debug_info_page==0 then
        show_text(0, 0, "HP: "..game:get_life().."/"..game:get_max_life())
        if game:get_max_magic() > 0 then
          show_text(0, 10, "MP: "..game:get_magic().."/"..game:get_max_magic())
        end
        if map then
          local x,y,layer=hero:get_position()
          show_text(0, 20, "Map: "..map:get_id())
          show_text(0, 30, "position: ("..x..";"..y..";"..layer..")")
          local w=map:get_world()
          if w then
            show_text(0, 40, "World: "..w)
            local wx,wy=map:get_location()
            show_text(0, 50, "XY (world): ("..x+wx..";"..y+wy..")")
          end
        end
        show_text(0, 60, "state: "..s..(s=="custom" and "("..hero:get_state_object():get_description()..")" or ""))
        show_text(0, 70, "ground:"..hero:get_ground_below())
        show_text(0, 80, "jumping? "..(hero:is_jumping() and "Yes" or "No"))
        show_text(100, 80, "Running? "..(hero:is_running() and "Yes" or "No")) 
        show_text(200, 80, "Invincible? "..(hero:is_invincible() and "Yes" or "No"))
        if hero_movement then 
          local mtype=sol.main.get_type(hero_movement)
          show_text(0, 100, "Movement info (type: "..mtype..")")

          --Common movement infos
          local x,y=hero_movement:get_xy()
          show_text(0, 110, "Position: ("..x..", "..y..")")
          show_text(0, 120, "Direction 4: " ..hero_movement:get_direction4())
          show_text(0,130, "Ignore obstacles? "..(hero_movement:get_ignore_obstacles() and "Yes" or "No"))
          show_text(0,140, "Ignore suspended with game? "..(hero_movement:get_ignore_suspend() and "Yes" or "No"))


          if hero_movement.get_speed then
            show_text(0, 150, "Speed: "..hero_movement:get_speed().." px/s")
          end
          if hero_movement.get_angle then
            show_text(0, 160, "Angle: "..hero_movement:get_angle().." rad")
          end
          if hero_movement.get_max_distance then
            show_text(0, 170, "Max distance: "..hero_movement:get_max_distance().." px")
          end
          if hero_movement.is_smooth then
            show_text(0, 180, "Smooth? "..(hero_movement:is_smooth() and "Yes" or "No"))
          end

          if mtype=="path_movement" then --Path movement
            local text="Path: "
            for k,v in pairs(hero_movement:get_path()) do
              text=text..v
            end
            show_text(0, 170, text)
            show_text(0, 180, "Snap to grid? "..(hero_movement:get_snap_to_grid() and "Yes" or "No"))
          end             
          if mtype=="circle_movement" then
            show_text(0, 150, "A.Speed: "..hero_movement:get_anguler_speed().." rad/s")
            show_text(0, 160, "Circular Angle: "..hero_movement:get_angle_from_center().." rad")
            show_text(0, 170, "Radius: "..hero_movement:get_radius().." px")
            show_text(0, 180, "Radiud speed: "..hero_movement:get_radius_speed().."px/s")
            show_text(0, 190, "Clockwise? "..(hero_movement:is_clockwise() and "Yes" or "No"))
            show_text(0, 200, "Max rotations: "..hero_movement:get_max_rotations())
            show_text(0, 210, "Duration: "..hero_movement:get_duration().." ms")
            show_text(0, 220, "Loop delay: "..hero_movement:get_loop_delay().." ms")
          end
          if mtype=="jump_movement" then
            show_text(0, 160, "Direction 8: "..hero_movement:get_direction8())
            show_text(0, 170, "Jump distance: "..hero_movement:get_distance()..' px')
          end
          if mtype=="pixel_movement" then
            show_text(0, 160, "Trajectory: "..hero_movement:get_trajectory())
            show_text(0, 170, "Delay: "..hero_movement:get_delay()..' ms')
          end
        end
      elseif debug_info_page == 1 then
        if s=="custom" then
          local state=hero:get_state_object()
          show_text(0,0,"Custom state info")
          show_text(0,10,"Description: "..state:get_description())
          show_text(0,20,"Visible ? "..(state:is_visible() and "Yes" or "No"))
          show_text(0,30,"Can traverse :")
          local can_traverse
          local num_cols=3
          for index, ground_type in pairs({"empty", "traversable", "wall", "low_wall", "wall_top_right", "wall_top_left", "wall_bottom_left", "wall_bottom_right", "wall_top_right_water", "wall_top_left_water", "wall_bottom_left_water", "wall_bottom_right_water", "deep_water", "shallow_water", "grass", "hole", "ice", "ladder", "prickles", "lava"}) do
            can_traverse=state:get_can_traverse_ground(ground_type)
            if can_traverse then
              debug_informations_text:set_color({0,255,0})
            else
              debug_informations_text:set_color({255,0,0})                     
            end
            local w=debug_informations_background:get_size()
            show_text((index-1)%num_cols*(w/num_cols), 40+10*math.floor((index-1)/num_cols), ground_type)
          end
--          for index, entity_type in pairs({"hero", "dynamic_tile", "teletransporter", "destination", "pickable", "destructible", "carried_object", "chest", "shop_treasure", "enemy", "npc", "block", "jumper", "switch", "sensor", "separator", "wall", "crystal", "crystal_block", "stream", "door", "stairs", "bomb", "explosion", "fire", "arrow", "hookshot", "boomerang", "custom_entity")
--            if is_affected then
--              debug_informations_text:set_color({0,192,0})
--            else
--              debug_informations_text:set_color({192,0,0})                     
--            end
--            show_text(index%4*90, 40+10*math.floor(index/4), entity_type)
--          end
          --TODO add all rules display (on a new page?)
        else
          show_text(0,0, "<No custom state data>")
        end
      else -- page 3
        show_text(0,0,"sprites information")
        local i=10
        for name, sprite in hero:get_sprites() do
          show_text(0,i,string.format("%s %s %s %d/%d" ..tostring(sprite:is_paused()), name, sprite:get_animation_set(), sprite:get_animation(), sprite:get_frame(), sprite:get_num_frames()-1))
            i=i+10
        end
      end

      debug_informations_background:draw(dst_surface)

      --Show cuttently active command keys
    end
  end
end

sol.menu.start(sol.main, debug)

return true
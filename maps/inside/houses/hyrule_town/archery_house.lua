local map = ...
local game = map:get_game()

local cannonball_manager = require("scripts/maps/cannonball_manager")

local hits = 0
local arrows_remaining
local playing_archery = false
local minigame_done = false
local current_arrows

function map:on_started()

  -- Not currently playing.
  map:set_entities_enabled("cannon_1",false)
  map:set_entities_enabled("target",false)
  map:set_entities_enabled("display",false)
  map:open_doors("door_minigame")
end

-- Game finished.
function end_minigame()
  hero:teleport(map:get_id(),"front_manager")
  sol.timer.start(1000,function()
    sol.audio.play_music("inside/house")
    game:start_dialog("maps.houses.hyrule_town.archery_house.results_calculate",function()
      hero:freeze()
      manager:get_sprite():set_direction(0)
      sol.timer.start(1000,function()
        manager:get_sprite():set_direction(3)
        hero:unfreeze()
        if hits >= 8 then
          game:start_dialog("maps.houses.hyrule_town.archery_house.results_win",function()
              if game:get_value("inside_hyrule_town_archery_game_piece_of_heart") ~= true then
                -- First time playing, give piece of heart.
                hero:start_treasure("piece_of_heart", 1, "inside_hyrule_town_archery_game_piece_of_heart", function()
                  game:start_dialog("maps.houses.hyrule_town.archery_house.results_win")
                end)
              else
                if game:get_value("get_quiver_3") then
                    --Mini-jeu déjà gagné, on donne au joueur de l'argent
                    hero:start_treasure("rupee",4,"",function()
                      game:start_dialog("maps.houses.hyrule_town.archery_house.results_win_2")
                    end)
                else
                  if game:get_value("great_fairy_1_offering_done") then
                  --On donne l'upgrade 2 du carquois
                    hero:start_treasure("quiver",3,"get_quiver_3",function()
                      game:start_dialog("maps.houses.hyrule_town.archery_house.results_win_2")
                    end)
                  else
                    --Mini-jeu déjà gagné, on donne au joueur de l'argent
                    hero:start_treasure("rupee",4,"",function()
                      game:start_dialog("maps.houses.hyrule_town.archery_house.results_win_2")
                    end)
                  end
                end
              end
          end)
        else
          game:start_dialog("maps.houses.hyrule_town.archery_house.results_lose")
        end
      end)
    end)
  end)  
end

function minigame_manager()
  arrows_remaining = 10
  hits = 0
  playing_archery = true
  sol.timer.start(map,300,function()
    if hero:get_animation() == "bow" then
      arrows_remaining = arrows_remaining - 1
      print("arrows:".. arrows_remaining)
    end
    if map:get_entity("target"):get_sprite():get_animation() == "hurt" then
      hits = hits + 1
      sol.audio.play_sound("menus/select")
      map:set_entities_enabled("display_counter",false)
      map:set_entities_enabled("display_counter_"..hits,true)
      if hits == 10 then map:set_entities_enabled("display_counter_perfect",true) end
    end
    if arrows_remaining == 0 then
      arrows_remaining = 1000
      sol.timer.start(1200,function()
        game:start_dialog("maps.houses.hyrule_town.archery_house.playing_end",function()
          game:get_item("bow"):set_amount(current_arrows)
          map:set_entities_enabled("cannon_1",false)
          map:set_entities_enabled("target",false)
          map:open_doors("door_minigame")
          manager:get_sprite():set_direction(3)
          playing_archery = false
          minigame_done = true
          return
          end_minigame()         
        end)  
      end)
    end
    return true
  end)
end

function manager:on_interaction()
  if playing_archery then
    game:start_dialog("maps.houses.hyrule_town.archery_house.already_playing")
  elseif not game:has_item("bow") then
    game:start_dialog("maps.houses.hyrule_town.archery_house.not_bow")
  else
    if minigame_done then
      game:start_dialog("maps.houses.hyrule_town.archery_house.playing_finished")
    else
      game:start_dialog("maps.houses.hyrule_town.archery_house.play_question",function(answer)
        if answer == 1 then
          -- Checking if Link has enough money.
          if game:get_money() >= 40 then
            game:remove_money(40)
            game:start_dialog("maps.houses.hyrule_town.archery_house.playing_yes",function()
              manager:get_sprite():set_direction(3)
              current_arrows = game:get_item("bow"):get_amount()
              game:get_item("bow"):set_amount(10)
              hero:teleport(map:get_id(),"minigame_start")
              sol.timer.start(1000,function()
                game:start_dialog("maps.houses.hyrule_town.archery_house.playing_start",function()
                  map:set_entities_enabled("cannon_1",true)
                  map:set_entities_enabled("target",true)
                  map:set_entities_enabled("display_target",true)
                  map:set_entities_enabled("display_counter_0",true)
                  map:close_doors("door_minigame")
                  sol.audio.play_music("inside/minigame_oot")
                  cannonball_manager:create_cannons(map, "cannon_")
                  minigame_manager()
                end)
              end)
            end)
          else
            sol.audio.play_sound("wrong")
            game:start_dialog("maps.houses.hyrule_town.archery_house.not_enough_money")
          end
        else
          game:start_dialog("maps.houses.hyrule_town.archery_house.playing_no")
        end
      end) 
    end
  end 
end

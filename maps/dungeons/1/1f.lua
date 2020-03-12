local map= ...
local game = map:get_game()

require("scripts/maps/separator_manager")

function welcome:on_activated()
  game:start_dialog("maps.dungeons.1.welcome")
end

function map:on_started()
  door_28_e_top:set_enabled(false)
  after_boss:set_enabled(true)
	auto_enemy_boss:set_enabled(false)
  boss_door:set_open(true)
end

function door_28_e_sensor:on_collision_explosion()
  door_28_e_top:set_enabled(true)
  door_28_e_tile:set_enabled(false)
  sol.audio.play_sound("common/secret_discover_minor")
end

function sensor_e_22_rsp:on_activated()
  hero:save_solid_ground()
end

function switch_door_23_n1:on_activated()
  door_23_n1:open()
  sol.timer.start(map, 15000, function()
      door_23_n1:close()
  end)
end


function mini_boss_sensor:on_activated()
  map:close_doors("mini_boss_boss_door")
  sol.audio.play_music("miniboss")
end

function auto_enemy_mini_boss:on_dead()
  map:open_doors("mini_boss_boss_door")
  sol.audio.play_music("dungeon/grave")
end

--Exit the dungeon once the boss defeated
function auto_enemy_boss:on_dead()
  sol.timer.start(map, 2000, function()
    hero:start_victory()
    sol.audio.play_music("victory", function()
       after_boss:set_enabled(true)
    end)
  end)
end

function boss_sensor:on_activated()
	auto_enemy_boss:set_enabled(true)
  map:close_doors("boss_door")
  game:start_dialog("maps.dungeons.1.boss_welcome")
  sol.audio.play_music("boss")
end
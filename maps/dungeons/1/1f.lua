local map= ...
local game = map:get_game()

function map:on_started()
  door_28_e_top:set_enabled(false)
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
  sol.timer.start(25000, function()
      door_23_n1:close()
  end)
end

--Exit the dungeon once the boss defeated
function boss_e:on_dead()
  sol.timer.start(map, 2000, function()
    hero:start_victory()
    sol.audio.play_music(music_id, function()
      sol.timer.start(map, 2000, function()
        hero:teleport("out/a1", from_dungeon)
      end)
    end)
  end)
end

function boss_s:on_activated()
  map:close_doors("boss_door")
  sol.audio.play_music("boss")
end
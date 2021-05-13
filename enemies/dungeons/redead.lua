local enemy = ...
	local audio_manager = require("scripts/audio_manager.lua")
  local attacking_hero = false
  local being_pushed = false
  local main_sprite = nil
  local sword_sprite = nil
  
  function enemy:on_created()
    enemy:set_life(16)
    enemy:set_damage(4)
    enemy:set_hurt_style("monster")
    main_sprite = enemy:create_sprite("enemies/dungeons/redead")
    enemy:set_size(16, 16)
    enemy:set_origin(8, 13)
  end
  
  function enemy:on_restarted()
    if not being_pushed then
      if attacking_hero then
        enemy:go_hero()
      else
        enemy:go_random()
        enemy:check_hero()
      end
    end
  end
  
  function enemy:check_hero()
    local map = enemy:get_map()
    local hero = map:get_hero()
    local _, _, layer = enemy:get_position()
    local _, _, hero_layer = hero:get_position()
    local near_hero = layer == hero_layer
        and enemy:get_distance(hero) < 80
        and enemy:is_in_same_region(hero)

    if near_hero and not attacking_hero then
      enemy:go_hero()
    elseif not near_hero and attacking_hero then
      enemy:go_random()
    end
    sol.timer.stop_all(self)
    sol.timer.start(self, 1000, function() enemy:check_hero() end)
  end
  
  function enemy:on_movement_changed(movement)
    if not being_pushed then
      local direction4 = movement:get_direction4()
      main_sprite:set_direction(direction4)
    end
  end
  
  function enemy:on_movement_finished(movement)
    if being_pushed then
      enemy:go_hero()
    end
  end
  
  function enemy:on_obstacle_reached(movement)
    if being_pushed then
      enemy:go_hero()
    end
  end

  
  function enemy:go_random()
    local movement = sol.movement.create("random_path")
    movement:set_speed(32)
    movement:start(enemy)
    being_pushed = false
    attacking_hero = false
  end
  
  function enemy:go_hero()
    local movement = sol.movement.create("random_path")
    movement:stop(enemy)
		local map = enemy:get_map()
    local hero = map:get_hero()
		hero:start_poison(1, 1000, 12)
		hero:start_slow(12000)
		audio_manager:play_sound("enemies/redead")
    being_pushed = false
    attacking_hero = true
  end
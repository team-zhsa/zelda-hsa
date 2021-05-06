local enemy = ...
	local audio_manager = require("scripts/audio_manager.lua")
  local going_hero = false
  local being_pushed = false
  local main_sprite = nil
  local sword_sprite = nil
  
  function enemy:on_created()
    enemy:set_life(16)
    enemy:set_damage(6)
    enemy:set_hurt_style("normal")
    sword_sprite = enemy:create_sprite("enemies/soldiers/sword_soldier_green_weapon")
    main_sprite = enemy:create_sprite("enemies/soldiers/sword_soldier_green")
    enemy:set_size(16, 16)
    enemy:set_origin(8, 13)

    enemy:set_invincible_sprite(sword_sprite)
    enemy:set_attack_consequence_sprite(sword_sprite, "sword", "custom")
  end
  
  function enemy:on_restarted()
    if not being_pushed then
      if going_hero then
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
        and enemy:get_distance(hero) < 128
        and enemy:is_in_same_region(hero)

    if near_hero and not going_hero then
      enemy:go_hero()
    elseif not near_hero and going_hero then
      enemy:go_random()
    end
    sol.timer.stop_all(self)
    sol.timer.start(self, 1000, function() enemy:check_hero() end)
  end
  
  function enemy:on_movement_changed(movement)
    if not being_pushed then
      local direction4 = movement:get_direction4()
      main_sprite:set_direction(direction4)
      sword_sprite:set_direction(direction4)
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
  
  function enemy:on_custom_attack_received(attack, sprite)
    if attack == "sword" and sprite == sword_sprite then
      audio_manager:play_sound("sword_tapping")
      being_pushed = true
      local map = enemy:get_map()
      local hero = map:get_hero()
      local x, y = enemy:get_position()
      local angle = hero:get_angle(enemy)
      local movement = sol.movement.create("straight")
      movement:set_speed(128)
      movement:set_angle(angle)
      movement:set_max_distance(26)
      movement:set_smooth(true)
      movement:start(enemy)
    end
  end
  
  function enemy:go_random()
    local movement = sol.movement.create("random_path")
    movement:set_speed(48)
    movement:start(enemy)
    being_pushed = false
    going_hero = false
  end
  
  function enemy:go_hero()
    local movement = sol.movement.create("target")
    movement:set_speed(64)
    movement:start(enemy)
		audio_manager:play_sound("hero_seen")
    being_pushed = false
    going_hero = true
  end

  -- Prevent enemies from "piling up" as much, which makes it easy to kill multiple in one hit.
  function enemy:on_collision_enemy(other_enemy, other_sprite, my_sprite)
    if enemy:is_traversable() then
      enemy:set_traversable(true) --default false
      sol.timer.start(200, function() enemy:set_traversable(true) end)
    end
  end
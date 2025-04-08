-- Lua script of enemy genie.
-- This script is executed every time an enemy with this model is created.

-- Variables
local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local bottle
local genie_bottle
local movement_first_step
local movement_first_step_angle = 0
local movement_first_step_distance = 48

-- Event called when the enemy is initialised.
function enemy:on_created()

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(0)
  enemy:set_hurt_style("boss")
  enemy:set_visible(false)
  enemy:set_invincible(true)
  enemy:set_layer(map:get_max_layer())


end

function enemy:launch_after_first_dialog()
  
  -- Create Bottle and start first step
  enemy:create_bottle()
  enemy:start_first_step()
  
end

function enemy:create_bottle()
  
  genie_bottle = enemy:create_enemy({
    breed = "boss/genie/genie_bottle",
    layer = 0,
    x = 0,
    y = 0,
    direction = direction
  })
  genie_bottle:set_genie(enemy)
  
end

function enemy:start_first_step()
  
  sol.timer.start(enemy, 1000, function()
    genie_bottle:go_initial_place()
  end)
  
end

function enemy:appear()
  
  local x_bottle,y_bottle, layer_bottle = genie_bottle:get_position()
  enemy:set_position(x_bottle, y_bottle - 32)
  enemy:set_visible(true)
  sprite:set_animation("appearing", function()
    sprite:set_animation("walking")
    game:start_dialog("maps.dungeons.2.boss_message_1", function()
      enemy:fight()
    end)
  end)
  
end

function enemy:disappear()
  
  local x_bottle,y_bottle, layer_bottle = genie_bottle:get_position()
  enemy:set_position(x_bottle, y_bottle - 32)
  sprite:set_animation("disappearing", function()
    enemy:set_visible(false)
    genie_bottle:fight()
  end)
  
end

function enemy:fight()
  
  movement_first_step = sol.movement.create("straight")
  movement_first_step:set_max_distance(movement_first_step_distance)
  movement_first_step:set_angle(movement_first_step_angle)
  movement_first_step:set_speed(50)
  movement_first_step:set_ignore_obstacles(true)
  movement_first_step:start(enemy, function()
    if movement_first_step_angle == 0 then
      movement_first_step_angle = math.pi
    else
      movement_first_step_angle = 0
    end
    movement_first_step_distance = 96
    enemy:fight()
  end)
  sol.timer.start(enemy, 5000, function()
    movement_first_step:stop()
    local x_bottle,y_bottle, layer_bottle = genie_bottle:get_position()
    movement_first_step = sol.movement.create("target")
    movement_first_step:set_target(x_bottle, y_bottle - 32)
    movement_first_step:set_speed(50)
    movement_first_step:start(enemy, function()
      enemy:disappear()
    end)
  end)

end


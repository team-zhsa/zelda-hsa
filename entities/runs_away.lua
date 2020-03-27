local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = map:get_hero()
local sprite
local movement
local dashing
--adjustable stats
local detection_distance = 65
local walking_speed = 10
local running_speed = 10
local dash_distance = 80
local dash_speed = 10

function entity:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function entity:on_update()
  if moement ~= nil then movement:stop() end
  dashing = false
  entity:go_random()
  entity:check_hero()
end

function entity:check_hero()
  local dist_hero = entity:get_distance(hero)
  local _,_,hero_layer = hero:get_position()
  local _,_,entity_layer = entity:get_position()
  if entity_layer == hero_layer and dist_hero < detection_distance and not dashing then
    entity:run_away()
  elseif not dashing then
    entity:go_random()
  end

  sol.timer.start(entity, 100, function() entity:check_hero() end)

end

function entity:run_away()
  local angle = entity:get_angle(hero)
  angle = angle + math.pi
  movement = sol.movement.create("straight")
  movement:set_angle(angle)
  movement:set_speed(running_speed)
  movement:start(entity) 
end

function entity:go_random()
  movement = sol.movement.create("random_path")
  movement:set_speed(walking_speed)
  movement:start(entity)
end

function entity:on_obstacle_reached()
  entity:dash()
end

function entity:dash()
  dashing = true
  movement = sol.movement.create("straight")
  movement:set_angle(math.random(2*math.pi))
  movement:set_speed(dash_speed)
  movement:set_max_distance(dash_distance)
  movement:start(enemy, function()
    dashing = false
    entity:go_random()
  end)
end

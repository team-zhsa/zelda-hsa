local state=sol.state.create("drowning")


state:set_can_use_item(false)
state:set_can_be_hurt(false)
state:set_can_control_direction(false)
state:set_can_control_movement(false)
state:set_can_use_sword(false)
state:set_can_use_jumper(false)
state:set_can_use_shield(false)
state:set_can_use_stairs(false)
state:set_can_traverse(true)
state:set_can_pick_treasure(false)
state:set_can_push(false)

for _, ground in pairs{"empty", "traversable", "wall", "low_wall", "wall_top_right", "wall_top_left", "wall_bottom_left", "wall_bottom_right", "wall_top_right_water", "wall_top_left_water", "wall_bottom_left_water", "wall_bottom_right_water", "deep_water", "shallow_water", "grass", "hole", "ice", "ladder", "prickles", "lava"} do
  state:set_can_traverse_ground(ground, true)
  state:set_affected_by_ground(ground, false)
end

state:register_event("on_started", function(state)
    local hero=state:get_game():get_hero()
    hero:set_visible()
    local s=hero:get_sprite("tunic")
    s:set_animation("drowning", function()
        -- print (animation, frame)
        hero:set_visible(false)
        local m=sol.movement.create("target")
        m:set_speed(88)
        m:set_ignore_obstacles(true)
        local dest_x, dest_y, dest_layer, direction=hero:get_last_stable_position()
        --print ("DESTX", dest_x, "DESTY", dest_y, "DESTL", dest_layer, "DESTDIR", direction)
        m:set_target(dest_x, dest_y) --TODO extract respawn point
        m:start(hero, function()
            hero:set_position(dest_x, dest_y, dest_layer)
            local m=hero:get_movement()
            hero:set_direction(direction/2)
            hero:respawn()
            hero:set_visible(true)
            hero:unfreeze()
          end)
      end)
  end)

local hero_meta=sol.main.get_metatable("hero")

function hero_meta.drown(hero)
  local s,c=hero:get_state()
  if s~="custom" or c:get_description()~="drowning" then
    hero:start_state(state)
  end  
end

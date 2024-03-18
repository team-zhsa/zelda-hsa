--[[
  Updated running custom state state.
  This script aims to reproduce the natural bahavior of the running shoes of Zelda : Link's Akakening
  It enables running into special obstacles to make things fall (or at least it tries to), and lets the hero jump without changing state.
  To use, require this file in your speed-ability item script, then
  call hero:run()
--]]
local state = sol.state.create("running")
local hero_meta=sol.main.get_metatable("hero")
local jump_manager
local audio_manager=require("scripts/audio_manager")
local map_tools=require("scripts/maps/map_tools")

state:set_can_use_item(false)
state:set_can_use_item("feather", true)
state:set_can_traverse("crystal_block", false)
state:set_can_use_jumper(true)
state:set_jumper_delay(0)

local directions = {
  {
    key="right",
    direction=0,
  },
  {
    key="up",
    direction=1,
  },
  {
    key="left",
    direction=2,
  },
  {
    key="down",
    direction=3,
  },
}

--This is the function to call to start the whole running process
function hero_meta.run(hero)
  local current_state=hero:get_state()
  if current_state~="custom" or hero:get_state_object():get_description()~="running" then
      --In sideviews, only allow to run sideways
      hero:start_state(state)
  end
end

--Stops and detaches the timer that enables the running sound to play frm the entity
local function stop_sound_loop(entity)
  if entity.run_sound_timer~= nil then
    entity.run_sound_timer:stop()
    entity.run_sound_timer = nil
  end
end

-- Create a new sword sprite to not trigger the "sword" attack on collision with enemies.
local function create_running_sword(entity, direction)

  local animation_set = entity:get_sprite("sword"):get_animation_set()
  local sprite=entity:get_sprite("running_sword") or entity:create_sprite(animation_set, "running_sword")
  sprite:set_animation("sword_loading_walking")
  sprite:set_direction(direction)

  return sprite
end

function state:on_started()
--  debug_print "Run, Forrest, ruuun !"
  local entity=state:get_entity()
  local game = state:get_game()
  local map = entity:get_map()
  local hero = map:get_hero()
  local sprite=entity:get_sprite("tunic")
	local running_speed = 256
	local ladder_running_speed = 16
  entity:get_sprite("trail"):set_animation("running") 
  sprite:set_animation("walking")

  -- initialise state abilities that may have changed.
  state:set_can_be_hurt(true)
  state:set_can_control_direction(true)
  state:set_can_control_movement(true)

  --Start playing the running sound
  entity.run_sound_timer = sol.timer.start(state, 200, function()
      if not entity.is_jumping or not entity:is_jumping() then
        if entity:get_ground_below() == "shallow_water" then
          audio_manager:play_sound("walk_on_water")
        elseif entity:get_ground_below()=="grass" then
          audio_manager:play_sound("walk_on_grass")
        else
          audio_manager:play_sound("running")
        end
        return true
      end
    end)

  --Prepare for running...
  entity.running_timer=sol.timer.start(state, 500, function() --start movement and pull out sword if any
      entity.running_timer=nil --TODO check if this isn't useless 
      entity.running=true
      local sword_sprite

      state:set_can_be_hurt(false)
      state:set_can_control_direction(false)
      state:set_can_control_movement(false)
      if game:get_ability("sword") then
        sprite:set_animation("sword_loading_walking")
        sword_sprite = create_running_sword(hero, sprite:get_direction())
      end

      local running_movement=sol.movement.create("straight")
	      running_movement:set_angle(sprite:get_direction()*math.pi/2)
				running_movement:set_speed(running_speed)

      -- Check if there is a collision with any sprite of the hero and an enemy, then hurt it.
      function running_movement:on_position_changed()

        for enemy in map:get_entities_by_type("enemy") do
          if hero:overlaps(enemy, "sprite") and enemy:get_life() > 0 and not enemy:is_immobilized() then
            local reaction = enemy:get_thrust_reaction()
            if reaction ~= "ignored" then
              enemy:receive_attack_consequence("thrust", reaction)
            elseif enemy:get_can_attack() then
              -- Hurt the hero if enemy ignore thrust attacks.
              hero:start_hurt(enemy, enemy:get_damage())
            end
          end
        end
      end

      function running_movement:on_obstacle_reached()
        require ("scripts/states/bonking")(jump_manager)
        stop_sound_loop(entity)
        self:stop()
        local x,y,w,h=entity:get_bounding_box()
        local ox, oy=hero:get_position()
        local map_w, map_h=map:get_size()
        local direction=entity:get_direction()
          entity:bonk()
      end
      --Run !
      running_movement:start(entity)

    end)
end

--Stops the run when the player changes the diection
function state:on_command_pressed(command)

  local entity=state:get_entity()
  if entity.running then
    local game=entity:get_game()
    local sprite=entity:get_sprite()

    --Stop running on direction change, unless we just bonked into an obstacle
    if not entity.bonking then
      for _,candidate in pairs(directions) do
        if candidate.key == command and candidate.direction~=sprite:get_direction() then
          entity:unfreeze()
          return true
        end
      end
    end
  end
end

--Stops the running preparation if the ACTION command is released
function state:on_command_released(command)
  if command == "action" then
    local entity=state:get_entity()
    if entity.running_timer~=nil then
      entity:unfreeze()
      return true
    end
  end
  local game = state:get_game()
  for i=1, 2 do
    local item =game:get_item_assigned(""..i)
    if command == "item_"..i and item and item:get_name()=="pegasus_shoes" then
      local entity=state:get_entity()
      if entity.running_timer~=nil then
        entity:unfreeze()
        return true
      end
    end
  end
end

function state:on_finished()
  local entity=state:get_entity()
  local sword_sprite = entity:get_sprite("running_sword")

  entity:get_sprite("trail"):stop_animation()
  if sword_sprite then
    entity:remove_sprite(sword_sprite)
  end

  entity.running=nil
  entity:stop_movement()
end

return function(_jump_manager)
  jump_manager=_jump_manager
end


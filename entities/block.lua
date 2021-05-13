-- Lua script of custom entity block.
-- By Daniel Molina and Alex Gleason, licensed under GPL-3.0-or-later

require("scripts/utils")

local entity = ...
local game = entity:get_game()
local map = entity:get_map()


-- Moves an entity in the 16x16 grid
local function grid_movement(d4)
  local m = sol.movement.create("straight")
  m:set_max_distance(16)
  m:set_speed(30)
  m:set_angle(d4_to_angle(d4))
  return m
end

-- Event called when the custom entity is initialized.
function entity:on_created()
  self:set_traversable_by(false)
  self:set_can_traverse(false)
  self:set_drawn_in_y_order()
  self._cooldown = sol.timer.start(self, 0, function() end)
end

-- Handle the hero pushing/pulling the entity
function entity:on_update()
  local hero = game:get_hero()
  local d4 = hero:get_direction()

  if not self:can_move() then
    return -- skip
  end

  if self:is_being_pushed() then self:push(d4) end
  if self:is_being_pulled() then self:pull(invert_d4(d4)) end
end

-- Push the entity
function entity:push(d4)
  log("Entity is being pushed")

  -- Set hero state
  local hero = game:get_hero()
  hero:freeze()
  hero:get_sprite():set_animation("pushing")

  -- Move entity
  local m = grid_movement(d4)
  function m:on_obstacle_reached()
    entity:stop_movement()
    hero:unfreeze()
  end
  m:start(self, function()
    entity:stop_movement() -- HACK: solarus-games/solarus#1396
    --entity:snap_to_grid()
  end)

  -- Move hero
  local m_hero = grid_movement(d4)
  m_hero:set_smooth()
  m_hero:start(hero, function()
    hero:unfreeze()
    hero:start_grabbing()
    entity:start_cooldown()
  end)
end

-- Pull the entity
function entity:pull(d4)
  log("Entity is being pulled")

  -- Set hero state
  local hero = game:get_hero()
  hero:freeze()
  hero:get_sprite():set_animation("pulling")

  -- Move entity
  local m = grid_movement(d4)
  m:start(self, function()
    entity:stop_movement() -- HACK: solarus-games/solarus#1396
    entity:start_cooldown()
    --entity:snap_to_grid()
  end)

  -- Move hero
  local m_hero = grid_movement(d4)
  m_hero:set_smooth()
  function m_hero:on_obstacle_reached()
    hero:unfreeze()
    hero:start_grabbing()
    entity:stop_movement() -- HACK: solarus-games/solarus#1396
  end
  m_hero:start(hero, function()
    hero:unfreeze()
    hero:start_grabbing()
  end)
end

-- Check if hero can move the entity (boolean)
function entity:can_move()
  return not self:is_moving() and self._cooldown:get_remaining_time() == 0
end

-- Check whether the entity is currently being pushed/pulled (boolean)
function entity:is_moving()
  return entity:get_movement() and true or false
end

-- Check whether the entity is being pushed (boolean)
function entity:is_being_pushed()
  local hero = game:get_hero()
  return self:overlaps(hero, "facing") and hero:get_state() == "pushing"
end

-- Check whether the entity is being pulled (boolean)
function entity:is_being_pulled()
  local hero = game:get_hero()
  return self:overlaps(hero, "facing") and hero:get_state() == "pulling"
end

-- Cooldown between pulling/pushing by 1 tile
function entity:start_cooldown()
  self._cooldown:stop()
  self._cooldown = sol.timer.start(self, 500, function() end)
end
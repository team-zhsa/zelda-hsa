----------------------------------
--
-- A handle that can be pulled and come back to its inital place.
--
-- Events :  pull_handle:on_pulling(movement_count)
--           pull_handle:on_released()
--
----------------------------------
-- TODO: on_grabbed(), set_max_moves()

local pull_handle = ...
local game = pull_handle:get_game()
local map = pull_handle:get_map()

-- Include scripts
require("scripts/multi_events")

-- Event called when the custom entity is initialized.
pull_handle:register_event("on_created", function()

  local movement_count = 0
  local initial_x, initial_y, initial_layer = pull_handle:get_position()

  -- Custom entity properties
  pull_handle:set_traversable_by("hero", false)
  pull_handle:set_drawn_in_y_order(true)
  pull_handle:set_enabled(false) -- Disable the initial entity instead of hiding it to not conflict with the block grab.

  -- Create the chain.
  local handle_chain = map:create_custom_entity({
    name = "handle_chain",
    x = initial_x,
    y = initial_y,
    layer = initial_layer,
    direction = 0,
    sprite = "entities/handle_chain",
    width = 8,
    height = 8
  })
  handle_chain:set_traversable_by("hero", false)
  handle_chain:set_tiled(true)
  handle_chain:set_drawn_in_y_order(true)

  -- Create a block to pull, not directly possible with custom entities for now.
  local handle_block = map:create_block({
    name = "handle_block",
    layer = initial_layer,
    x = initial_x,
    y = initial_y,
    direction = 3,
    sprite = pull_handle:get_sprite():get_animation_set(),
    pushable = false,
    pullable = true,
    max_moves = 4,
    enabled_at_start = true})
  handle_block:set_drawn_in_y_order(true)

  -- Switch the pull_handle and handle_block position and activation.
  local function switch_handle_entities()
    local x, y, layer = pull_handle:get_position()
    pull_handle:set_position(handle_block:get_position())
    handle_block:set_position(x, y, layer)
    pull_handle:set_enabled(not pull_handle:is_enabled())
    handle_block:set_enabled(not handle_block:is_enabled())
  end

  -- Return the distance in pixel between the entity y position and the initial position.
  local function get_y_gap(entity)
    local _, entity_y = entity:get_position()
    return  entity_y - initial_y
  end

  -- Setup the return movement when the hero release the handle.
  local hero = map:get_hero()
  hero:register_event("on_state_changing", function(hero, state_name, next_state_name)
    local is_released = (state_name == "pulling" or state_name == "grabbing" or state_name == "pushing") and next_state_name == "free"
    if is_released and get_y_gap(handle_block) ~= 0 then

      -- Apply the go back movement to the initial custom entity to avoid traversable blocks behavior when moved.
      switch_handle_entities()
      local movement = sol.movement.create("straight")
      movement:set_angle(math.pi / 2)
      movement:set_speed(10)
      movement:set_max_distance(get_y_gap(pull_handle))
      movement:set_smooth(false)
      movement:start(pull_handle)

      -- Resize the chain while going back to initial place.
      function movement:on_position_changed()
        local y_gap = get_y_gap(pull_handle)
        if y_gap > 0 then
          handle_chain:set_size(8, y_gap)
        end
      end

      -- Switch handle entities to be able to pull it again and reset move count when the movement finished.
      function movement:on_finished()
        switch_handle_entities()
        handle_block:reset() 
        movement_count = 0
      end

      -- Call the released event.
      if pull_handle.on_released then
        pull_handle:on_released()
      end
    end
  end)

  -- Behavior at the beginning of each pull.
  function handle_block:on_moving()
    movement_count = movement_count + 1

    -- Call the pulling event.
    if pull_handle.on_pulling then
      pull_handle:on_pulling(movement_count)
    end

    -- Resize the chain.
    handle_chain:set_size(8, get_y_gap(handle_block) + 16)
  end
end)
local item = ...
local game = item:get_game()

local magic_needed = 2 -- Number of magic points required.

function item:on_created()
  self:set_sound_when_brandished("items/get_major_item")
  item:set_savegame_variable("possession_lamp")
  item:set_assignable(true)
end

function item:on_obtained()
  game:set_step_done("lamp_obtained")
end

-- Shoots some fire on the map.
function item:shoot()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()

  local x, y, layer = hero:get_center_position()
  local fire = map:create_custom_entity({
    model = "fire",
    x = x,
    y = y + 3,
    layer = layer,
    width = 8,
    height = 8,
    direction = direction,
  })

 -- local fire_sprite = entity:get_sprite("fire")
  --fire_sprite:set_animation("flying")
	sol.audio.play_sound("items/lamp/on")
  local angle = direction * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(fire)
end

function item:on_using()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()
--[[  hero:set_animation("rod")

  -- Give the hero the animation of using the fire rod.
  local x, y, layer = hero:get_position()
  local fire_rod = map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    width = 16,
    height = 16,
    direction = direction,
    sprite = "hero/item/lamp/on",
  })--]]

  -- Shoot fire if there is enough magic.
  if game:get_magic() >= magic_needed then
    sol.audio.play_sound("items/lamp/on")
    game:remove_magic(magic_needed)
    item:shoot()
  end

  -- Make sure that the fire rod stays on the hero.
  -- Even if he is using this item, he can move
  -- because of holes or ice.
 -- sol.timer.start(fire_rod, 10, function()
 --   fire_rod:set_position(hero:get_position())
   -- return true
 -- end)

  -- Remove the fire rod and restore control after a delay.
  sol.timer.start(hero, 300, function()
 --   fire_rod:remove()
    item:set_finished()
  end)
end

-- initialise the metatable of appropriate entities to work with the fire.
local function initialise_meta()

  -- Add Lua fire properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_fire_reaction ~= nil then
    -- Already done.
    return
  end

  enemy_meta.fire_reaction = 2  -- 7 life points by default.
  enemy_meta.fire_reaction_sprite = {}
  function enemy_meta:get_fire_reaction(sprite)

    if sprite ~= nil and self.fire_reaction_sprite[sprite] ~= nil then
      return self.fire_reaction_sprite[sprite]
    end
    return self.fire_reaction
  end

  function enemy_meta:set_fire_reaction(reaction, sprite)

    self.fire_reaction = reaction
  end

  function enemy_meta:set_fire_reaction_sprite(sprite, reaction)

    self.fire_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account the fire.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_fire_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_fire_reaction_sprite(sprite, "ignored")
  end

end
initialise_meta()

local item = ...
local game = item:get_game()

local magic_needed = 1 -- Number of magic points required.

function item:on_created()
  self:set_sound_when_brandished("items/get_major_item")
  item:set_savegame_variable("possession_rod_thunder")
  item:set_assignable(true)
end

-- Shoots some thunder on the map.
function item:shoot()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()

  local x, y, layer = hero:get_center_position()
  local thunder = map:create_custom_entity({
    model = "thunder",
    x = x,
    y = y - 8,
    layer = layer,
    width = 16,
    height = 16,
    direction = direction,
  })

	sol.audio.play_sound("items/rod_thunder")
  local angle = direction * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(thunder)
end

function item:on_using()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()
  hero:set_animation("rod")

  -- Give the hero the animation of using the thunder rod.
  local x, y, layer = hero:get_position()
  local rod_thunder = map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    width = 16,
    height = 16,
    direction = direction,
    sprite = "hero/item/rods/rod_thunder",
  })

  -- Shoot thunder if there is enough magic.
  if game:get_magic() >= magic_needed then
    --sol.audio.play_sound("lamp")
    game:remove_magic(magic_needed)
    item:shoot()
  end

  -- Make sure that the thunder rod stays on the hero.
  -- Even if he is using this item, he can move
  -- because of holes or thunder.
  sol.timer.start(rod_thunder, 10, function()
    rod_thunder:set_position(hero:get_position())
    return true
  end)

  -- Remove the thunder rod and restore control after a delay.
  sol.timer.start(hero, 300, function()
    rod_thunder:remove()
    item:set_finished()
  end)
end

-- initialise the metatable of appropriate entities to work with the thunder.
local function initialise_meta()

  -- Add Lua thunder properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_thunder_reaction ~= nil then
    -- Already done.
    return
  end

  enemy_meta.thunder_reaction = 3  -- 3 life points by default.
  enemy_meta.thunder_reaction_sprite = {}
  function enemy_meta:get_thunder_reaction(sprite)

    if sprite ~= nil and self.thunder_reaction_sprite[sprite] ~= nil then
      return self.thunder_reaction_sprite[sprite]
    end
    return self.thunder_reaction
  end

  function enemy_meta:set_thunder_reaction(reaction, sprite)

    self.thunder_reaction = reaction
  end

  function enemy_meta:set_thunder_reaction_sprite(sprite, reaction)

    self.thunder_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account the thunder.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_thunder_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_thunder_reaction_sprite(sprite, "ignored")
  end

end
initialise_meta()

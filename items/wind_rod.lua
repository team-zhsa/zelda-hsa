local item = ...
local game = item:get_game()

local magic_needed = 13 -- Number of magic points required.

function item:on_created()

  item:set_savegame_variable("possession_wind_rod")
  item:set_assignable(true)
end

-- Shoots some wind on the map.
function item:shoot()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()

  local x, y, layer = hero:get_center_position()
  local wind = map:create_custom_entity({
    model = "rod_wind",
    x = x,
    y = y + 3,
    layer = layer,
    width = 8,
    height = 8,
    direction = direction,
  })

	sol.audio.play_sound("wind")
  local angle = direction * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(wind)
end

function item:on_using()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()
  hero:set_animation("rod")

  -- Give the hero the animation of using the wind rod.
  local x, y, layer = hero:get_position()
  local wind_rod = map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    width = 16,
    height = 16,
    direction = direction,
    sprite = "hero/item/rods/wind_rod",
  })

  -- Shoot wind if there is enough magic.
  if game:get_magic() >= magic_needed then
    --sol.audio.play_sound("lamp")
    game:remove_magic(magic_needed)
    item:shoot()
  end

  -- Make sure that the wind rod stays on the hero.
  -- Even if he is using this item, he can move
  -- because of holes or ice.
  sol.timer.start(wind_rod, 10, function()
    wind_rod:set_position(hero:get_position())
    return true
  end)

  -- Remove the wind rod and restore control after a delay.
  sol.timer.start(hero, 300, function()
    wind_rod:remove()
    item:set_finished()
  end)
end

-- initialise the metatable of appropriate entities to work with the wind.
local function initialise_meta()

  -- Add Lua wind properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_wind_reaction ~= nil then
    -- Already done.
    return
  end

  enemy_meta.wind_reaction = 3  -- 3 life points by default.
  enemy_meta.wind_reaction_sprite = {}
  function enemy_meta:get_wind_reaction(sprite)

    if sprite ~= nil and self.wind_reaction_sprite[sprite] ~= nil then
      return self.wind_reaction_sprite[sprite]
    end
    return self.wind_reaction
  end

  function enemy_meta:set_wind_reaction(reaction, sprite)

    self.wind_reaction = reaction
  end

  function enemy_meta:set_wind_reaction_sprite(sprite, reaction)

    self.wind_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account the wind.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_wind_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_wind_reaction_sprite(sprite, "ignored")
  end

end
initialise_meta()

local item = ...
local game = item:get_game()

local magic_needed = 0 -- Number of magic points required.

function item:on_created()

  item:set_savegame_variable("possession_sword_beam")
  item:set_assignable(true)
end

-- Shoots some beam on the map.
function item:shoot()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()

  local x, y, layer = hero:get_center_position()
  local beam = map:create_custom_entity({
    model = "sword_beam",
    x = x - 8,
    y = y + 3,
    layer = layer,
    width = 48,
    height = 48,
    direction = direction,
  })

	sol.audio.play_sound("boss_fireball")
  local angle = direction * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(beam)
end

function item:on_using()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()
	local sword = self:get_game():get_item("sword"):get_variant()
  hero:set_animation("sword_tapping")
  hero:set_direction(direction)
  local x, y, layer = hero:get_position()
  local sword_spr = map:create_custom_entity({
    x = x,
    y = y,
    layer = layer,
    width = 16,
    height = 16,
    direction = direction,
    sprite = "hero/sword" .. sword,
  })

  if game:get_life() == game:get_max_life() then
    item:shoot()
  end

  sol.timer.start(sword_spr, 10, function()
    sword_spr:set_position(hero:get_position())
    return true
  end)

  -- Remove the swod sprite and restore control after a delay.
  sol.timer.start(hero, 500, function()
    sword_spr:remove()
    item:set_finished()
  end)
end

-- Initialize the metatable of appropriate entities to work with the beam.
local function initialize_meta()

  -- Add Lua beam properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_beam_reaction ~= nil then
    -- Already done.
    return
  end

  enemy_meta.beam_reaction = 2  -- 3 life points by default.
  enemy_meta.beam_reaction_sprite = {}
  function enemy_meta:get_beam_reaction(sprite)

    if sprite ~= nil and self.beam_reaction_sprite[sprite] ~= nil then
      return self.beam_reaction_sprite[sprite]
    end
    return self.beam_reaction
  end

  function enemy_meta:set_beam_reaction(reaction, sprite)

    self.beam_reaction = reaction
  end

  function enemy_meta:set_beam_reaction_sprite(sprite, reaction)

    self.beam_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account the beam.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_beam_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_beam_reaction_sprite(sprite, "ignored")
  end

end
initialize_meta()

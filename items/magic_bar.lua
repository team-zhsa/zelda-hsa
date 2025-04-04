local item = ...

function item:on_created()
  self:set_savegame_variable("possession_magic_bar")
  self:set_sound_when_brandished("items/get_major_item")
end

function item:on_variant_changed(variant)
  -- Obtaining a magic bar changes the max magic.
  local max_magics = {39, 79, 119} -- Must be 5 units less than sprite dimensions
  local max_magic = max_magics[variant]
  if max_magic == nil then
    error("Invalid variant '" .. variant .. "' for item 'magic_bar'")
  end
  self:get_game():set_max_magic(max_magic)

  -- Unlock pickable magic jars.
  local magic_flask = self:get_game():get_item("magic_flask")
  magic_flask:set_obtainable(true)
end

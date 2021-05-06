local item = ...

-- When it is created, this item creates another item randomly chosen
-- and then destroys itself.

-- Probability of each item between 0 and 200.
local probabilities = {
  [{ "rupee", 1 }]      = 22,   -- 1 rupee.
  [{ "rupee", 2 }]      = 20,   -- 5 rupees.
  [{ "heart", 1 }]      = 20,   -- Heart.
  [{ "bomb", 1}]        = 25,   -- Bomb.
  [{ "bomb", 2}]        = 22,  -- 3 Bombs.
  [{ "arrow", 3 }]      = 15,   --  10 Arrows.
  [{ "arrow", 2 }]      = 12,   --  8 Arrows.
  [{ "seashell", 1 }]      = 20,   --  Seashell.
	[{ "magic_flask", 1 }]      = 20,   --  Magic Flask.
	[{ "magic_flask", 2 }]      = 12,   --  Magic Flask.
}

function item:on_pickable_created(pickable)

  local treasure_name, treasure_variant = self:choose_random_item()
  if treasure_name ~= nil then
    local map = pickable:get_map()
    local x, y, layer = pickable:get_position()
    map:create_pickable{
      layer = layer,
      x = x,
      y = y,
      treasure_name = treasure_name,
      treasure_variant = treasure_variant,
    }
  end
  pickable:remove()
end

-- Returns an item name and variant.
function item:choose_random_item()

  local random = math.random(200)
  local sum = 0

  for key, probability in pairs(probabilities) do
    sum = sum + probability
    if random < sum then
      return key[1], key[2]
    end
  end

  return nil
end